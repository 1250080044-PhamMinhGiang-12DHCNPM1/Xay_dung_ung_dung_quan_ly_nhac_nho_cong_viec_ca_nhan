import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'config.dart';
import 'local_db.dart';

/// Lỗi trả về từ API (message tiếng Việt lấy từ field "message" của response chuẩn).
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Dio dùng chung cho cả app.
/// Interceptor:
///  - onRequest: đọc token trong SQLite, gắn header `Authorization: Bearer <token>`.
///  - onError 401 (khi đã gửi token): token hết hạn/không hợp lệ/tài khoản bị khóa
///    → xóa phiên trong SQLite và quay về màn Đăng nhập.
class ApiClient {
  /// Dùng để điều hướng từ nơi không có BuildContext (interceptor).
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// main.dart gán hàm này để AuthProvider xóa user khỏi bộ nhớ khi phiên hết hạn.
  static VoidCallback? onSessionExpired;

  static final Dio dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final session = await LocalDb.getSession();
        if (session != null) {
          options.headers['Authorization'] = 'Bearer ${session.token}';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final sentToken = error.requestOptions.headers.containsKey('Authorization');
        // Chỉ xử lý 401 khi request có gửi token (401 của màn đăng nhập là sai mật khẩu)
        if (error.response?.statusCode == 401 && sentToken) {
          await LocalDb.clearSession();
          onSessionExpired?.call();
          final message = _messageFromResponse(error.response) ?? 'Phiên đăng nhập đã hết hạn';
          final context = navigatorKey.currentContext;
          if (context != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
          }
          navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
        }
        handler.next(error);
      },
    ));
    return dio;
  }

  /// Gọi API và trả về field "data" của response chuẩn { success, message, data }.
  /// Lỗi (mất mạng, 4xx, 5xx) đều đổi thành ApiException để màn hình hiển thị message.
  /// Ví dụ: final data = await ApiClient.send(() => ApiClient.dio.get('/auth/me'));
  static Future<dynamic> send(Future<Response<dynamic>> Function() request) async {
    final body = await sendRaw(request);
    return body['data'];
  }

  /// Giống send nhưng trả cả body (khi cần đọc "message" của response thành công).
  static Future<Map<String, dynamic>> sendRaw(
      Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw ApiException(body['message'] as String? ?? 'Có lỗi xảy ra', response.statusCode);
      }
      return body;
    } on DioException catch (e) {
      throw ApiException(_describe(e), e.response?.statusCode);
    }
  }

  static String _describe(DioException e) {
    final fromApi = _messageFromResponse(e.response);
    if (fromApi != null) return fromApi;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Máy chủ phản hồi quá lâu, vui lòng thử lại';
      case DioExceptionType.connectionError:
        return 'Không kết nối được máy chủ (${AppConfig.baseUrl})';
      default:
        return 'Có lỗi xảy ra (${e.response?.statusCode ?? e.type.name})';
    }
  }

  static String? _messageFromResponse(Response<dynamic>? response) {
    final data = response?.data;
    if (data is Map && data['message'] is String && (data['message'] as String).isNotEmpty) {
      return data['message'] as String;
    }
    return null;
  }
}
