/// Phiên đăng nhập lưu trong bảng SQLite `session` (luôn chỉ có 1 dòng, id = 1).
class Session {
  final int userId;
  final String email;
  final String fullName;
  final String role;
  final String token;
  final DateTime expiresAt;

  Session({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
    required this.token,
    required this.expiresAt,
  });

  bool get isAdmin => role == 'Admin';

  /// Token đã hết hạn chưa (so với giờ hiện tại).
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Tạo từ data của POST /api/auth/login: {token, expiresAt, user{...}}
  factory Session.fromLoginJson(Map<String, dynamic> data) {
    final user = data['user'] as Map<String, dynamic>;
    return Session(
      userId: user['id'] as int,
      email: user['email'] as String,
      fullName: user['fullName'] as String,
      role: user['role'] as String,
      token: data['token'] as String,
      expiresAt: DateTime.parse(data['expiresAt'] as String).toLocal(),
    );
  }

  /// Chuyển sang Map để lưu vào SQLite (tên cột theo docs/DATABASE.md).
  Map<String, Object?> toMap() => {
        'id': 1,
        'user_id': userId,
        'email': email,
        'full_name': fullName,
        'role': role,
        'token': token,
        'expires_at': expiresAt.toUtc().toIso8601String(),
      };

  factory Session.fromMap(Map<String, Object?> map) => Session(
        userId: map['user_id'] as int,
        email: map['email'] as String,
        fullName: map['full_name'] as String,
        role: map['role'] as String,
        token: map['token'] as String,
        expiresAt: DateTime.parse(map['expires_at'] as String).toLocal(),
      );
}
