import 'package:flutter/foundation.dart';

import '../core/local_db.dart';

/// Kế hoạch nháp (giỏ hàng) - An hoàn thiện ở task 04.
/// Hiện tại chỉ có số mục để hiển thị badge trên icon Kế hoạch.
class PlanDraftProvider extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  /// Đọc lại số mục trong bảng plan_draft (gọi sau khi thêm/xóa mục).
  Future<void> refreshCount() async {
    _count = await LocalDb.countPlanDraft();
    notifyListeners();
  }
}
