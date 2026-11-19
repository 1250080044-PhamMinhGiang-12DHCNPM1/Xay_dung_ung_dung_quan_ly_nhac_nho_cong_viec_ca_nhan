import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/plan_draft_provider.dart';
import '../../services/notification_service.dart';
import '../admin/admin_screen.dart';
import '../plan/plan_draft_screen.dart';
import '../profile/profile_screen.dart';
import '../task/my_tasks_screen.dart';
import 'home_screen.dart';

/// Khung chính sau khi đăng nhập: bottom navigation
/// Trang chủ | Công việc | Kế hoạch (badge) | Tài khoản | Quản trị (chỉ Admin).
/// Lưu ý: ẩn tab Quản trị chỉ để giao diện gọn; phân quyền thật nằm ở API (403).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Vào màn chính sau đăng nhập thì xin quyền thông báo + báo thức chính xác (task 04)
    NotificationService.requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;
    final draftCount = context.watch<PlanDraftProvider>().count;

    final pages = <Widget>[
      const HomeScreen(),
      const MyTasksScreen(),
      const PlanDraftScreen(),
      const ProfileScreen(),
      if (isAdmin) const AdminScreen(),
    ];

    final destinations = <NavigationDestination>[
      const NavigationDestination(
          icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Trang chủ'),
      const NavigationDestination(
          icon: Icon(Icons.checklist_outlined), selectedIcon: Icon(Icons.checklist), label: 'Công việc'),
      NavigationDestination(
        icon: Badge(
          isLabelVisible: draftCount > 0,
          label: Text('$draftCount'),
          child: const Icon(Icons.event_note_outlined),
        ),
        selectedIcon: Badge(
          isLabelVisible: draftCount > 0,
          label: Text('$draftCount'),
          child: const Icon(Icons.event_note),
        ),
        label: 'Kế hoạch',
      ),
      const NavigationDestination(
          icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Tài khoản'),
      if (isAdmin)
        const NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: 'Quản trị'),
    ];

    // Phòng trường hợp số tab giảm (vd đăng nhập lại bằng Member)
    final index = _index < pages.length ? _index : 0;

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: destinations,
      ),
    );
  }
}
