import '../core/api_client.dart';
import '../models/paged_result.dart';
import '../models/user.dart';

/// Admin quản lý member: /api/users (API chặn bằng [Authorize(Roles = "Admin")]).
class UserService {
  /// GET /users?keyword&page&pageSize
  Future<PagedResult<UserListItem>> getUsers({String? keyword, int page = 1, int pageSize = 10}) async {
    final data = await ApiClient.send(() => ApiClient.dio.get('/users', queryParameters: {
          if (keyword != null && keyword.trim().isNotEmpty) 'keyword': keyword.trim(),
          'page': page,
          'pageSize': pageSize,
        }));
    return PagedResult.fromJson(data as Map<String, dynamic>, UserListItem.fromJson);
  }

  /// PUT /users/{id}/role  {role}
  Future<String> updateRole(int id, String role) async {
    final body = await ApiClient.sendRaw(
        () => ApiClient.dio.put('/users/$id/role', data: {'role': role}));
    return body['message'] as String? ?? '';
  }

  /// PUT /users/{id}/lock  {isLocked}
  Future<String> updateLock(int id, bool isLocked) async {
    final body = await ApiClient.sendRaw(
        () => ApiClient.dio.put('/users/$id/lock', data: {'isLocked': isLocked}));
    return body['message'] as String? ?? '';
  }
}
