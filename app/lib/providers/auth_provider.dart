import 'package:flutter/foundation.dart';

import '../models/session.dart';
import '../services/auth_service.dart';

/// Giữ phiên đăng nhập hiện tại cho toàn app (Provider).
/// Màn hình dùng `context.watch<AuthProvider>().isAdmin` để ẩn/hiện menu Quản trị.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Session? _session;
  Session? get session => _session;
  bool get isLoggedIn => _session != null;
  bool get isAdmin => _session?.isAdmin ?? false;

  /// Splash gọi khi mở app: đọc phiên trong SQLite, hết hạn thì xóa.
  Future<void> loadSession() async {
    final saved = await _authService.currentSession();
    if (saved != null && saved.isExpired) {
      await _authService.logout();
      _session = null;
    } else {
      _session = saved;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _session = await _authService.login(email, password);
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _session = null;
    notifyListeners();
  }

  /// ApiClient gọi khi gặp 401 (phiên đã bị xóa khỏi SQLite trước đó).
  void handleSessionExpired() {
    _session = null;
    notifyListeners();
  }
}
