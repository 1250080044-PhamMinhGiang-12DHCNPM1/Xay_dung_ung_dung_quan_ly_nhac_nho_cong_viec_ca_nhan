import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';

/// Tài khoản: thông tin người dùng, đổi mật khẩu, đăng xuất.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Đăng xuất')),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;

    // Xóa phiên trong SQLite rồi về màn đăng nhập (xóa hết lịch sử điều hướng)
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthProvider>().session;

    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản')),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 40,
            child: Text(
              (session?.fullName.isNotEmpty ?? false) ? session!.fullName[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(height: 12),
          Text(session?.fullName ?? '',
              textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
          Text(session?.email ?? '', textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Center(
            child: Chip(
              label: Text(session?.isAdmin == true ? 'Quản trị viên' : 'Thành viên'),
            ),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text('Đổi mật khẩu'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).pushNamed('/change-password'),
          ),
          // ----- Nhắc nhở (task 04): demo thông báo cục bộ -----
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Thử thông báo ngay'),
            onTap: () async {
              await NotificationService.requestPermissions();
              await NotificationService.showTest();
            },
          ),
          ListTile(
            leading: const Icon(Icons.alarm_add_outlined),
            title: const Text('Thử nhắc sau 1 phút'),
            subtitle: const Text('Đặt lịch rồi tắt hẳn app để kiểm tra'),
            onTap: () async {
              await NotificationService.requestPermissions();
              final at = await NotificationService.scheduleTest();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Đã đặt nhắc lúc ${TimeOfDay.fromDateTime(at).format(context)}'),
              ));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
