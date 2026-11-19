import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/formatters.dart';
import '../../models/plan.dart';
import '../../services/plan_service.dart';
import '../../widgets/app_network_image.dart';

/// Chi tiết kế hoạch đã chốt: ngày, trạng thái, ghi chú, danh sách công việc và thời lượng.
class PlanDetailScreen extends StatefulWidget {
  final int planId;

  const PlanDetailScreen({super.key, required this.planId});

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  static final _dateFormat = DateFormat('dd/MM/yyyy');

  PlanDetail? _plan;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final plan = await PlanService().getDetail(widget.planId);
      if (mounted) setState(() => _plan = plan);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết kế hoạch')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_error!, textAlign: TextAlign.center),
          TextButton(onPressed: _load, child: const Text('Thử lại')),
        ]),
      );
    }
    final plan = _plan;
    if (plan == null) return const Center(child: CircularProgressIndicator());

    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ListTile(
          leading: const Icon(Icons.event),
          title: Text(_dateFormat.format(plan.planDate), style: theme.textTheme.titleLarge),
          subtitle: Text('Mã kế hoạch #${plan.id}'),
          trailing: Chip(label: Text(PlanSummary.statusLabel(plan.status))),
        ),
        ListTile(
          leading: const Icon(Icons.timer_outlined),
          title: Text('Tổng thời lượng: ${formatMinutes(plan.totalMinutes)}'),
          subtitle: Text('${plan.items.length} công việc'),
        ),
        if ((plan.note ?? '').isNotEmpty)
          ListTile(
            leading: const Icon(Icons.notes),
            title: Text(plan.note!),
          ),
        const Divider(),
        ...plan.items.map((item) => ListTile(
              leading: AppNetworkImage(path: item.imageUrl, fallbackIcon: Icons.task_alt),
              title: Text(item.title),
              subtitle: Text(item.categoryName),
              trailing: Text(formatMinutes(item.minutes), style: theme.textTheme.titleSmall),
            )),
      ],
    );
  }
}
