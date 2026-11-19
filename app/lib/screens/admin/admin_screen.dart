import 'package:flutter/material.dart';

import '../../widgets/placeholder_view.dart';
import 'user_management_screen.dart';

/// Menu Quản trị (chỉ hiện với Admin).
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản trị')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Quản lý member'),
            subtitle: const Text('Tìm kiếm, đổi role, khóa tài khoản'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(context, const UserManagementScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Quản lý nhóm công việc'),
            trailing: const Icon(Icons.chevron_right),
            // Bảo (task 02) thay bằng màn hình thật trong screens/category/
            onTap: () => _open(
              context,
              const _AdminPlaceholder(
                title: 'Quản lý nhóm công việc',
                icon: Icons.category_outlined,
                owner: 'Trương Gia Bảo (task 02)',
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.assignment_outlined),
            title: const Text('Quản lý kế hoạch'),
            trailing: const Icon(Icons.chevron_right),
            // Hiếu (task 03) thay bằng màn hình thật trong screens/admin/
            onTap: () => _open(
              context,
              const _AdminPlaceholder(
                title: 'Quản lý kế hoạch',
                icon: Icons.assignment_outlined,
                owner: 'Trần Văn Hiếu (task 03)',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminPlaceholder extends StatelessWidget {
  final String title;
  final IconData icon;
  final String owner;

  const _AdminPlaceholder({required this.title, required this.icon, required this.owner});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PlaceholderView(icon: icon, title: title, owner: owner),
    );
  }
}
