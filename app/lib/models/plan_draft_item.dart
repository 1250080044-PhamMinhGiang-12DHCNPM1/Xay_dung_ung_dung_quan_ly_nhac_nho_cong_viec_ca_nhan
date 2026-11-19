/// Một dòng trong kế hoạch nháp (bảng SQLite `plan_draft`) - tương đương 1 món trong "giỏ hàng".
class PlanDraftItem {
  final int taskId;
  final String title;
  final String? imageUrl;
  final int minutes; // thời lượng dự kiến - tương đương "số lượng"
  final DateTime addedAt;

  PlanDraftItem({
    required this.taskId,
    required this.title,
    this.imageUrl,
    required this.minutes,
    required this.addedAt,
  });

  /// Tên cột theo docs/DATABASE.md: task_id, title, image_url, minutes, added_at
  Map<String, Object?> toMap() => {
        'task_id': taskId,
        'title': title,
        'image_url': imageUrl,
        'minutes': minutes,
        'added_at': addedAt.toIso8601String(),
      };

  factory PlanDraftItem.fromMap(Map<String, Object?> map) => PlanDraftItem(
        taskId: map['task_id'] as int,
        title: map['title'] as String,
        imageUrl: map['image_url'] as String?,
        minutes: map['minutes'] as int,
        addedAt: DateTime.parse(map['added_at'] as String),
      );
}
