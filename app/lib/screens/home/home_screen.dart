import 'package:flutter/material.dart';

import '../../widgets/placeholder_view.dart';

/// Trang chủ - Bảo (task 02): nhóm công việc, công việc mới nhất, theo nhóm, tìm kiếm.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trang chủ')),
      body: const PlaceholderView(
        icon: Icons.home_outlined,
        title: 'Trang chủ',
        owner: 'Trương Gia Bảo (task 02)',
      ),
    );
  }
}
