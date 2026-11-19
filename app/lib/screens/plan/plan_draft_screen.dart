import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../models/plan_draft_item.dart';
import '../../providers/plan_draft_provider.dart';
import '../../services/plan_service.dart';
import '../../widgets/app_network_image.dart';
import 'plan_detail_screen.dart';
import 'plan_history_screen.dart';

/// Kế hoạch nháp trong ngày (task 04 - An) - tương đương "giỏ hàng":
/// danh sách (SQLite), chỉnh phút ±15, xóa, tổng thời lượng, chọn ngày, ghi chú, chốt kế hoạch.
class PlanDraftScreen extends StatefulWidget {
  const PlanDraftScreen({super.key});

  @override
  State<PlanDraftScreen> createState() => _PlanDraftScreenState();
}

class _PlanDraftScreenState extends State<PlanDraftScreen> {
  static final _shortDate = DateFormat('dd/MM/yyyy');

  final _noteController = TextEditingController();
  final _planService = PlanService();
  DateTime _planDate = DateUtils.dateOnly(DateTime.now());
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _planDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      helpText: 'Ngày thực hiện kế hoạch',
    );
    if (picked != null) setState(() => _planDate = picked);
  }

  Future<void> _remove(PlanDraftItem item) async {
    await context.read<PlanDraftProvider>().remove(item.taskId);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Đã bỏ "${item.title}" khỏi kế hoạch nháp')));
  }

  /// Chốt kế hoạch: gửi toàn bộ nháp lên API (POST /plans, transaction phía server).
  /// Thành công → xóa nháp trong SQLite (badge về 0) → mở chi tiết kế hoạch vừa tạo.
  Future<void> _submit() async {
    final draft = context.read<PlanDraftProvider>();
    if (draft.items.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chốt kế hoạch'),
        content: Text('Chốt ${draft.count} công việc, tổng ${formatMinutes(draft.totalMinutes)} '
            'cho ngày ${_shortDate.format(_planDate)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Chốt')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _submitting = true);
    try {
      final plan = await _planService.create(
        planDate: _planDate,
        note: _noteController.text,
        items: draft.items,
      );
      await draft.clear();
      _noteController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã chốt kế hoạch')));
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PlanDetailScreen(planId: plan.id)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = context.watch<PlanDraftProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kế hoạch trong ngày'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Lịch sử kế hoạch',
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const PlanHistoryScreen())),
          ),
        ],
      ),
      body: draft.items.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Kế hoạch nháp đang trống.\nMở chi tiết một công việc và bấm "Thêm vào kế hoạch".',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                ...draft.items.map(_buildItem),
                const Divider(height: 24),
                ListTile(
                  leading: const Icon(Icons.event),
                  title: const Text('Ngày thực hiện'),
                  subtitle: Text(_shortDate.format(_planDate)),
                  trailing: const Icon(Icons.edit_calendar),
                  onTap: _pickDate,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _noteController,
                    maxLength: 500,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Ghi chú (không bắt buộc)'),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: draft.items.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${draft.count} công việc',
                              style: Theme.of(context).textTheme.bodySmall),
                          Text('Tổng: ${formatMinutes(draft.totalMinutes)}',
                              style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _submitting ? null : _submit,
                      icon: _submitting
                          ? const SizedBox(
                              width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.check),
                      label: const Text('Chốt kế hoạch'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildItem(PlanDraftItem item) {
    final draft = context.read<PlanDraftProvider>();
    return Dismissible(
      key: ValueKey(item.taskId),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red.shade400,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _remove(item),
      child: ListTile(
        leading: AppNetworkImage(path: item.imageUrl, fallbackIcon: Icons.task_alt),
        title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(formatMinutes(item.minutes)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stepper thời lượng: mỗi lần ±15 phút, trong khoảng 15 → 480 phút
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              tooltip: 'Bớt 15 phút',
              onPressed: item.minutes > PlanDraftProvider.minMinutes
                  ? () => draft.changeMinutes(item.taskId, -PlanDraftProvider.stepMinutes)
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Thêm 15 phút',
              onPressed: item.minutes < PlanDraftProvider.maxMinutes
                  ? () => draft.changeMinutes(item.taskId, PlanDraftProvider.stepMinutes)
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Bỏ khỏi kế hoạch',
              onPressed: () => _remove(item),
            ),
          ],
        ),
      ),
    );
  }
}
