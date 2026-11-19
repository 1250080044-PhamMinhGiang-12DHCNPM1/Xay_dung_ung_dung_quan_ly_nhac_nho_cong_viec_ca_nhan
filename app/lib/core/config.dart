/// Cấu hình địa chỉ API.
/// - Emulator Android: 10.0.2.2 trỏ về localhost của máy tính đang chạy API.
/// - Điện thoại thật: đổi thành IP LAN của máy tính, hoặc chạy
///   `flutter run --dart-define=API_URL=http://192.168.1.10:5080`.
class AppConfig {
  static const String baseUrl =
      String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:5080');

  static const String apiUrl = '$baseUrl/api';

  /// Đổi đường dẫn ảnh API trả về (/uploads/...) thành url đầy đủ để Image.network hiển thị.
  static String imageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$baseUrl$path';
  }
}
