import 'package:sqflite/sqflite.dart';

import '../core/local_db.dart';
import '../models/plan_draft_item.dart';

/// Thao tác CRUD trên bảng SQLite `plan_draft` (kế hoạch nháp - "giỏ hàng").
/// Dữ liệu nằm trong file task_reminder.db trên điện thoại → tắt app mở lại vẫn còn.
class PlanDraftRepository {
  static const _table = 'plan_draft';
  static const int defaultMinutes = 30;

  /// Đọc tất cả mục nháp, mục thêm trước đứng trước.
  /// SQL: SELECT * FROM plan_draft ORDER BY added_at
  Future<List<PlanDraftItem>> getAll() async {
    final db = await LocalDb.database;
    final rows = await db.query(_table, orderBy: 'added_at');
    return rows.map(PlanDraftItem.fromMap).toList();
  }

  /// Thêm 1 công việc vào nháp. Trả về false nếu công việc đã có (task_id là khóa chính).
  /// Kiểm tra trước bằng SELECT cho dễ hiểu, rồi mới INSERT.
  Future<bool> add({required int taskId, required String title, String? imageUrl}) async {
    final db = await LocalDb.database;
    final existing = await db.query(_table, where: 'task_id = ?', whereArgs: [taskId], limit: 1);
    if (existing.isNotEmpty) return false; // đã có trong nháp

    final item = PlanDraftItem(
      taskId: taskId,
      title: title,
      imageUrl: imageUrl,
      minutes: defaultMinutes,
      addedAt: DateTime.now(),
    );
    // SQL: INSERT INTO plan_draft(task_id, title, image_url, minutes, added_at) VALUES (?, ?, ?, ?, ?)
    await db.insert(_table, item.toMap(), conflictAlgorithm: ConflictAlgorithm.abort);
    return true;
  }

  /// Sửa số phút. SQL: UPDATE plan_draft SET minutes = ? WHERE task_id = ?
  Future<void> updateMinutes(int taskId, int minutes) async {
    final db = await LocalDb.database;
    await db.update(_table, {'minutes': minutes}, where: 'task_id = ?', whereArgs: [taskId]);
  }

  /// Xóa 1 mục. SQL: DELETE FROM plan_draft WHERE task_id = ?
  Future<void> remove(int taskId) async {
    final db = await LocalDb.database;
    await db.delete(_table, where: 'task_id = ?', whereArgs: [taskId]);
  }

  /// Đếm số mục (cho badge). SQL: SELECT COUNT(*) FROM plan_draft
  Future<int> count() => LocalDb.countPlanDraft();

  /// Xóa hết nháp (sau khi chốt kế hoạch thành công). SQL: DELETE FROM plan_draft
  Future<void> clear() async {
    final db = await LocalDb.database;
    await db.delete(_table);
  }
}
