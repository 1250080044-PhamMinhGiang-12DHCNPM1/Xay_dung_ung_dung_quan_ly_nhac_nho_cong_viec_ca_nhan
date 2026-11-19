import 'package:flutter/material.dart';

import '../../widgets/placeholder_view.dart';

/// Công việc của tôi - Hiếu (task 03): danh sách phân trang, thêm/sửa/xóa, upload ảnh.
class MyTasksScreen extends StatelessWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Công việc của tôi')),
      body: const PlaceholderView(
        icon: Icons.checklist,
        title: 'Công việc của tôi',
        owner: 'Trần Văn Hiếu (task 03)',
      ),
    );
  }
}
