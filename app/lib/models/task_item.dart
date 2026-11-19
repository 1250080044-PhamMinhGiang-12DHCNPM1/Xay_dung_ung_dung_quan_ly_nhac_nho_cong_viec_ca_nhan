/// Công việc: khớp TaskItemDto của API (dùng chung Trang chủ - task 02 và Công việc của tôi - task 03).
class TaskItem {
  final int id;
  final int categoryId;
  final String categoryName;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final int priority; // 1 thấp, 2 vừa, 3 cao
  final String status; // Todo | Doing | Done
  final String? imageUrl;
  final DateTime? reminderAt;
  final DateTime createdAt;

  TaskItem({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.title,
    this.description,
    this.dueDate,
    required this.priority,
    required this.status,
    this.imageUrl,
    this.reminderAt,
    required this.createdAt,
  });

  /// API trả giờ UTC (có "Z"), đổi sang giờ máy để hiển thị.
  static DateTime? _date(Object? value) =>
      value == null ? null : DateTime.parse(value as String).toLocal();

  factory TaskItem.fromJson(Map<String, dynamic> json) => TaskItem(
        id: json['id'] as int,
        categoryId: json['categoryId'] as int,
        categoryName: json['categoryName'] as String? ?? '',
        title: json['title'] as String,
        description: json['description'] as String?,
        dueDate: _date(json['dueDate']),
        priority: json['priority'] as int,
        status: json['status'] as String,
        imageUrl: json['imageUrl'] as String?,
        reminderAt: _date(json['reminderAt']),
        createdAt: _date(json['createdAt'])!,
      );

  String get priorityLabel => switch (priority) {
        1 => 'Thấp',
        3 => 'Cao',
        _ => 'Vừa',
      };

  String get statusLabel => switch (status) {
        'Doing' => 'Đang làm',
        'Done' => 'Hoàn thành',
        _ => 'Cần làm',
      };
}
