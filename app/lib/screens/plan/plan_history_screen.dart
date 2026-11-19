import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/formatters.dart';
import '../../models/plan.dart';
import '../../services/plan_service.dart';
import 'plan_detail_screen.dart';

/// Lịch sử kế hoạch của tôi: tìm theo ghi chú / tên công việc (debounce 400 ms), cuộn vô hạn.
class PlanHistoryScreen extends StatefulWidget {
  const PlanHistoryScreen({super.key});

  @override
  State<PlanHistoryScreen> createState() => _PlanHistoryScreenState();
}

class _PlanHistoryScreenState extends State<PlanHistoryScreen> {
  static final _dateFormat = DateFormat('dd/MM/yyyy');

  final _service = PlanService();
  final _scrollController = ScrollController();
  Timer? _debounce;
  String _keyword = '';

  final List<PlanSummary> _items = [];
  int _page = 0;
  bool _hasMore = true;
  bool _loading = false;
  String? _error;
  int _requestId = 0; // bỏ kết quả cũ khi từ khóa đã đổi

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final p = _scrollController.position;
      if (p.pixels >= p.maxScrollExtent - 200) _loadNextPage();
    });
    _loadNextPage();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadNextPage() async {
    if (_loading || !_hasMore) return;
    final requestId = _requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _service.getMyPlans(keyword: _keyword, page: _page + 1);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _items.addAll(result.items);
        _page = result.page;
        _hasMore = result.hasMore;
      });
    } catch (e) {
      if (mounted && requestId == _requestId) setState(() => _error = e.toString());
    } finally {
      if (mounted && requestId == _requestId) setState(() => _loading = false);
    }
  }

  Future<void> _reload() async {
    _requestId++;
    setState(() {
      _items.clear();
      _page = 0;
      _hasMore = true;
      _loading = false;
    });
    await _loadNextPage();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (value.trim() == _keyword) return;
      _keyword = value.trim();
      _reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử kế hoạch')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Tìm theo ghi chú hoặc tên công việc',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _reload,
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _items.length + 1,
                itemBuilder: (context, index) {
                  if (index < _items.length) return _buildPlan(_items[index]);
                  if (_loading) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (_error != null) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(children: [
                        Text(_error!, textAlign: TextAlign.center),
                        TextButton(onPressed: _loadNextPage, child: const Text('Thử lại')),
                      ]),
                    );
                  }
                  if (_items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: Text('Chưa có kế hoạch nào')),
                    );
                  }
                  return const SizedBox(height: 24);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlan(PlanSummary plan) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.event_note)),
      title: Text(_dateFormat.format(plan.planDate)),
      subtitle: Text(
        '${plan.itemCount} công việc · ${formatMinutes(plan.totalMinutes)}'
        '${(plan.note ?? '').isEmpty ? '' : '\n${plan.note}'}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      isThreeLine: (plan.note ?? '').isNotEmpty,
      trailing: Chip(
        label: Text(PlanSummary.statusLabel(plan.status)),
        visualDensity: VisualDensity.compact,
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PlanDetailScreen(planId: plan.id)),
      ),
    );
  }
}
