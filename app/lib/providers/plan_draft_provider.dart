import 'package:flutter/foundation.dart';

import '../models/plan_draft_item.dart';
import '../models/task_item.dart';
import '../services/plan_draft_repository.dart';

/// Kế hoạch nháp (giỏ hàng) dùng chung cho cả app (Provider).
/// Mỗi lần thêm/sửa/xóa: ghi SQLite qua repository, cập nhật danh sách trong bộ nhớ,
/// rồi notifyListeners() → badge trên icon Kế hoạch và màn nháp vẽ lại NGAY.
class PlanDraftProvider extends ChangeNotifier {
  static const int stepMinutes = 15;
  static const int minMinutes = 15;
  static const int maxMinutes = 480;

  final PlanDraftRepository _repository = PlanDraftRepository();

  List<PlanDraftItem> _items = [];
  List<PlanDraftItem> get items => _items;

  /// Số mục - hiển thị trên badge.
  int get count => _items.length;

  /// Tổng thời lượng dự kiến (phút).
  int get totalMinutes => _items.fold(0, (sum, i) => sum + i.minutes);

  bool contains(int taskId) => _items.any((i) => i.taskId == taskId);

  /// Đọc lại toàn bộ nháp từ SQLite (gọi khi mở app).
  Future<void> load() async {
    _items = await _repository.getAll();
    notifyListeners();
  }

  /// Giữ tên cũ cho SplashScreen (task 01) - đọc lại nháp từ SQLite.
  Future<void> refreshCount() => load();

  /// Nút "Thêm vào kế hoạch" ở màn chi tiết công việc (task 02) gọi hàm này.
  /// Trả về true nếu thêm mới, false nếu công việc đã có trong nháp.
  Future<bool> addToPlan(TaskItem task) async {
    final added = await _repository.add(taskId: task.id, title: task.title, imageUrl: task.imageUrl);
    if (added) await load();
    return added;
  }

  /// Tăng/giảm thời lượng theo bước 15 phút, giới hạn trong [15, 480].
  Future<void> changeMinutes(int taskId, int delta) async {
    final item = _items.firstWhere((i) => i.taskId == taskId);
    final minutes = (item.minutes + delta).clamp(minMinutes, maxMinutes);
    if (minutes == item.minutes) return;
    await _repository.updateMinutes(taskId, minutes);
    await load();
  }

  Future<void> remove(int taskId) async {
    await _repository.remove(taskId);
    await load();
  }

  /// Xóa hết nháp sau khi chốt kế hoạch thành công.
  Future<void> clear() async {
    await _repository.clear();
    await load();
  }
}
