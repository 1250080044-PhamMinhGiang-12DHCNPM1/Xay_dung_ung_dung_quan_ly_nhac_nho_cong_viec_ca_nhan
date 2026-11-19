/// Kế hoạch đã chốt (GET /api/plans, GET /api/plans/{id}).
class PlanSummary {
  final int id;
  final DateTime planDate; // chỉ có ngày ("yyyy-MM-dd"), không đổi múi giờ
  final String status;
  final int totalMinutes;
  final String? note;
  final int itemCount;

  PlanSummary({
    required this.id,
    required this.planDate,
    required this.status,
    required this.totalMinutes,
    this.note,
    required this.itemCount,
  });

  factory PlanSummary.fromJson(Map<String, dynamic> json) => PlanSummary(
        id: json['id'] as int,
        planDate: DateTime.parse(json['planDate'] as String),
        status: json['status'] as String,
        totalMinutes: json['totalMinutes'] as int,
        note: json['note'] as String?,
        itemCount: json['itemCount'] as int,
      );

  static String statusLabel(String status) => switch (status) {
        'InProgress' => 'Đang thực hiện',
        'Completed' => 'Hoàn thành',
        'Cancelled' => 'Đã hủy',
        _ => 'Đã chốt',
      };
}

class PlanDetail extends PlanSummary {
  final List<PlanItemInfo> items;

  PlanDetail({
    required super.id,
    required super.planDate,
    required super.status,
    required super.totalMinutes,
    super.note,
    required super.itemCount,
    required this.items,
  });

  factory PlanDetail.fromJson(Map<String, dynamic> json) {
    final s = PlanSummary.fromJson(json);
    return PlanDetail(
      id: s.id,
      planDate: s.planDate,
      status: s.status,
      totalMinutes: s.totalMinutes,
      note: s.note,
      itemCount: s.itemCount,
      items: (json['items'] as List)
          .map((e) => PlanItemInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PlanItemInfo {
  final int taskId;
  final String title;
  final String categoryName;
  final String? imageUrl;
  final int minutes;

  PlanItemInfo({
    required this.taskId,
    required this.title,
    required this.categoryName,
    this.imageUrl,
    required this.minutes,
  });

  factory PlanItemInfo.fromJson(Map<String, dynamic> json) => PlanItemInfo(
        taskId: json['taskId'] as int,
        title: json['title'] as String,
        categoryName: json['categoryName'] as String? ?? '',
        imageUrl: json['imageUrl'] as String?,
        minutes: json['minutes'] as int,
      );
}
