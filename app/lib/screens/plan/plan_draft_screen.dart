import 'package:flutter/material.dart';

import '../../widgets/placeholder_view.dart';

/// Kế hoạch nháp (giỏ hàng) - An (task 04): danh sách plan_draft, sửa phút, xóa, chốt kế hoạch.
class PlanDraftScreen extends StatelessWidget {
  const PlanDraftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kế hoạch trong ngày')),
      body: const PlaceholderView(
        icon: Icons.event_note,
        title: 'Kế hoạch trong ngày',
        owner: 'Nguyễn Hoài An (task 04)',
      ),
    );
  }
}
