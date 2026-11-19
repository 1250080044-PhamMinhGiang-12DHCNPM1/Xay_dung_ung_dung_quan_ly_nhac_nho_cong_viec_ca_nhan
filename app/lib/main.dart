import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/plan_draft_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/main_shell.dart';
import 'screens/profile/change_password_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  // Khi API trả 401 (token hết hạn / bị khóa), ApiClient đã xóa phiên trong SQLite,
  // báo cho AuthProvider để giao diện cập nhật theo.
  ApiClient.onSessionExpired = authProvider.handleSessionExpired;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => PlanDraftProvider()),
        // Bảo / Hiếu / An thêm provider của module mình ở đây.
      ],
      child: const TaskReminderApp(),
    ),
  );
}

class TaskReminderApp extends StatelessWidget {
  const TaskReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nhắc việc',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      navigatorKey: ApiClient.navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const MainShell(),
        '/change-password': (_) => const ChangePasswordScreen(),
      },
    );
  }
}
