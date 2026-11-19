import '../core/api_client.dart';
import '../core/local_db.dart';
import '../models/session.dart';
import '../models/user.dart';

/// Gọi các API /api/auth/* và quản lý phiên trong SQLite.
class AuthService {
  /// POST /auth/login → lưu phiên vào SQLite.
  Future<Session> login(String email, String password) async {
    final data = await ApiClient.send(() => ApiClient.dio.post('/auth/login', data: {
          'email': email.trim(),
          'password': password,
        }));
    final session = Session.fromLoginJson(data as Map<String, dynamic>);
    await LocalDb.saveSession(session);
    return session;
  }

  /// POST /auth/register → trả message của API.
  Future<String> register(String email, String password, String fullName) async {
    final body = await ApiClient.sendRaw(() => ApiClient.dio.post('/auth/register', data: {
          'email': email.trim(),
          'password': password,
          'fullName': fullName.trim(),
        }));
    return body['message'] as String? ?? 'Đăng ký thành công';
  }

  /// GET /auth/me
  Future<AppUser> me() async {
    final data = await ApiClient.send(() => ApiClient.dio.get('/auth/me'));
    return AppUser.fromJson(data as Map<String, dynamic>);
  }

  /// POST /auth/change-password
  Future<String> changePassword(String oldPassword, String newPassword) async {
    final body = await ApiClient.sendRaw(() => ApiClient.dio.post('/auth/change-password', data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }));
    return body['message'] as String? ?? 'Đổi mật khẩu thành công';
  }

  /// Đăng xuất: chỉ xóa phiên trong SQLite, không cần gọi server
  /// (JWT không lưu ở server; app không còn token thì không gọi được API cần đăng nhập).
  Future<void> logout() => LocalDb.clearSession();

  Future<Session?> currentSession() => LocalDb.getSession();
}
