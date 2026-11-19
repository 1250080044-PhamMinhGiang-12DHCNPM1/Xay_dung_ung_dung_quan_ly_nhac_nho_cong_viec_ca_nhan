/// Kết quả phân trang dùng chung: data = { items, page, pageSize, totalItems, totalPages }.
class PagedResult<T> {
  final List<T> items;
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  PagedResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  /// Còn trang sau không (để hiện "Tải thêm" / cuộn vô hạn).
  bool get hasMore => page < totalPages;

  /// [fromItem] chuyển từng phần tử JSON thành model, ví dụ UserListItem.fromJson.
  factory PagedResult.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromItem) {
    return PagedResult(
      items: (json['items'] as List)
          .map((e) => fromItem(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      totalItems: json['totalItems'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}
