/// Validate form phía app (API cũng validate lại, vì không tin dữ liệu từ client).
/// Quy tắc giống DTO bên API: email hợp lệ, mật khẩu 6-100 ký tự, họ tên tối đa 100 ký tự.
class Validators {
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Vui lòng nhập email';
    if (v.length > 150) return 'Email tối đa 150 ký tự';
    if (!_emailRegex.hasMatch(v)) return 'Email không hợp lệ';
    return null;
  }

  static String? required(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (v.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
    if (v.length > 100) return 'Mật khẩu tối đa 100 ký tự';
    return null;
  }

  static String? fullName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Vui lòng nhập họ tên';
    if (v.length > 100) return 'Họ tên tối đa 100 ký tự';
    return null;
  }
}
