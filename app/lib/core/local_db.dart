import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/session.dart';

/// CSDL SQLite trên điện thoại, file `task_reminder.db`.
/// - Bảng `session`: phiên đăng nhập (Giang).
/// - Bảng `plan_draft`: kế hoạch nháp - "giỏ hàng" (An viết thêm các hàm thêm/sửa/xóa).
class LocalDb {
  static const _dbName = 'task_reminder.db';
  static const _dbVersion = 1;

  static Database? _db;

  /// Mở CSDL một lần rồi dùng lại (lần đầu sẽ chạy onCreate để tạo bảng).
  static Future<Database> get database async {
    _db ??= await openDatabase(
      join(await getDatabasesPath(), _dbName),
      version: _dbVersion,
      onCreate: _onCreate,
    );
    return _db!;
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE session (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        user_id INTEGER NOT NULL,
        email TEXT NOT NULL,
        full_name TEXT NOT NULL,
        role TEXT NOT NULL,
        token TEXT NOT NULL,
        expires_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE plan_draft (
        task_id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        image_url TEXT,
        minutes INTEGER NOT NULL DEFAULT 30,
        added_at TEXT NOT NULL
      )
    ''');
  }

  // ---------------- session ----------------

  /// Lưu phiên sau khi đăng nhập. id luôn = 1 nên "replace" sẽ ghi đè phiên cũ.
  static Future<void> saveSession(Session session) async {
    final db = await database;
    await db.insert('session', session.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<Session?> getSession() async {
    final db = await database;
    final rows = await db.query('session', where: 'id = 1');
    if (rows.isEmpty) return null;
    return Session.fromMap(rows.first);
  }

  /// Đăng xuất = xóa phiên (token) khỏi máy. Không có token thì mọi API cần đăng nhập đều trả 401.
  static Future<void> clearSession() async {
    final db = await database;
    await db.delete('session');
  }

  // ---------------- plan_draft (An - task 04) ----------------

  /// Số mục trong kế hoạch nháp, dùng cho badge trên icon Kế hoạch.
  static Future<int> countPlanDraft() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) AS c FROM plan_draft');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
