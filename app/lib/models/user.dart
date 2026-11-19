/// Người dùng: data của GET /api/auth/me {id, email, fullName, role, avatarUrl}.
class AppUser {
  final int id;
  final String email;
  final String fullName;
  final String role;
  final String? avatarUrl;

  AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
  });

  bool get isAdmin => role == 'Admin';

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as int,
        email: json['email'] as String,
        fullName: json['fullName'] as String,
        role: json['role'] as String,
        avatarUrl: json['avatarUrl'] as String?,
      );
}

/// Một dòng trong danh sách member (GET /api/users - Admin).
class UserListItem {
  final int id;
  final String email;
  final String fullName;
  final String role;
  final bool isLocked;
  final bool emailConfirmed;
  final DateTime createdAt;

  UserListItem({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isLocked,
    required this.emailConfirmed,
    required this.createdAt,
  });

  bool get isAdmin => role == 'Admin';

  factory UserListItem.fromJson(Map<String, dynamic> json) => UserListItem(
        id: json['id'] as int,
        email: json['email'] as String,
        fullName: json['fullName'] as String,
        role: json['role'] as String,
        isLocked: json['isLocked'] as bool,
        emailConfirmed: json['emailConfirmed'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      );
}
