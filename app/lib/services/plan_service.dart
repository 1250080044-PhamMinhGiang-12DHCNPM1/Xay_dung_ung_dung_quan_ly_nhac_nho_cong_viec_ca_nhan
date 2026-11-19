import 'package:intl/intl.dart';

import '../core/api_client.dart';
import '../models/paged_result.dart';
import '../models/plan.dart';
import '../models/plan_draft_item.dart';

/// Gọi API /api/plans - kế hoạch của người đang đăng nhập.
class PlanService {
  static const int pageSize = 10;
  static final _dateParam = DateFormat('yyyy-MM-dd');

  /// POST /plans - chốt kế hoạch từ danh sách nháp (API tạo Plan + PlanItems trong 1 transaction).
  Future<PlanDetail> create({
    required DateTime planDate,
    String? note,
    required List<PlanDraftItem> items,
  }) async {
    final data = await ApiClient.send(() => ApiClient.dio.post('/plans', data: {
          'planDate': _dateParam.format(planDate), // chỉ gửi ngày
          if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
          'items': items.map((i) => {'taskId': i.taskId, 'minutes': i.minutes}).toList(),
        }));
    return PlanDetail.fromJson(data as Map<String, dynamic>);
  }

  /// GET /plans?keyword&page&pageSize
  Future<PagedResult<PlanSummary>> getMyPlans({String? keyword, required int page}) async {
    final data = await ApiClient.send(() => ApiClient.dio.get('/plans', queryParameters: {
          if (keyword != null && keyword.trim().isNotEmpty) 'keyword': keyword.trim(),
          'page': page,
          'pageSize': pageSize,
        }));
    return PagedResult.fromJson(data as Map<String, dynamic>, PlanSummary.fromJson);
  }

  /// GET /plans/{id}
  Future<PlanDetail> getDetail(int id) async {
    final data = await ApiClient.send(() => ApiClient.dio.get('/plans/$id'));
    return PlanDetail.fromJson(data as Map<String, dynamic>);
  }
}
