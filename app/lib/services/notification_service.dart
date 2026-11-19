import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/task_item.dart';

/// Nhắc nhở bằng thông báo cục bộ (task 04 - An), dùng flutter_local_notifications + timezone.
///
/// Cơ chế khi app TẮT: zonedSchedule không chạy trong app mà giao lịch cho AlarmManager của Android.
/// Đến giờ, Android gọi ScheduledNotificationReceiver (khai báo trong AndroidManifest.xml) để hiện
/// thông báo, nên app không cần đang mở. Khởi động lại máy thì ScheduledNotificationBootReceiver đặt lại lịch.
///
/// Quy ước (SPEC mục 7): ID thông báo = TaskId → sửa giờ nhắc / xóa công việc chỉ cần cancel(taskId).
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  /// ID dành cho thông báo thử (TaskId luôn >= 1 nên không trùng).
  static const int _testNotificationId = 0;

  static const AndroidNotificationDetails _androidDetails = AndroidNotificationDetails(
    'task_reminder', // id kênh thông báo
    'Nhắc việc', // tên kênh hiển thị trong Cài đặt Android
    channelDescription: 'Nhắc nhở khi đến giờ làm công việc',
    importance: Importance.high,
    priority: Priority.high,
  );
  static const NotificationDetails _details = NotificationDetails(android: _androidDetails);

  static AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  /// Khởi tạo 1 lần (gọi trong main): nạp dữ liệu múi giờ, đặt giờ Việt Nam, khởi tạo plugin.
  static Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _initialized = true;
  }

  /// Xin quyền:
  ///  - POST_NOTIFICATIONS (Android 13+): hiện hộp thoại cho phép thông báo.
  ///  - Báo thức chính xác (Android 12+): mở trang cài đặt nếu chưa được cấp.
  /// Trả về true nếu được phép hiện thông báo.
  static Future<bool> requestPermissions() async {
    await init();
    final android = _android;
    if (android == null) return true;
    final granted = await android.requestNotificationsPermission() ?? false;
    final canExact = await android.canScheduleExactNotifications() ?? false;
    if (!canExact) await android.requestExactAlarmsPermission();
    return granted;
  }

  /// Đặt lịch nhắc cho công việc tại task.reminderAt. Bỏ qua nếu không có giờ nhắc hoặc giờ đã qua.
  static Future<void> scheduleTaskReminder(TaskItem task) async {
    final reminderAt = task.reminderAt;
    if (reminderAt == null || !reminderAt.isAfter(DateTime.now())) return;

    await _schedule(
      id: task.id, // ID thông báo = TaskId
      at: reminderAt,
      title: 'Đến giờ: ${task.title}',
      body: task.description?.isNotEmpty == true ? task.description! : 'Nhóm: ${task.categoryName}',
    );
  }

  /// Hủy lịch nhắc của công việc (khi sửa giờ nhắc hoặc xóa công việc).
  static Future<void> cancelTaskReminder(int taskId) async {
    await init();
    await _plugin.cancel(id: taskId);
  }

  /// Nút "Thử thông báo ngay" (màn Tài khoản): hiện thông báo tức thì.
  static Future<void> showTest() async {
    await init();
    await _plugin.show(
      id: _testNotificationId,
      title: 'Thông báo thử',
      body: 'Nhắc nhở công việc đang hoạt động',
      notificationDetails: _details,
    );
  }

  /// Nút "Thử nhắc sau 1 phút": đặt lịch 1 phút sau. Tắt hẳn app để kiểm tra vẫn nhận được.
  static Future<DateTime> scheduleTest({Duration after = const Duration(minutes: 1)}) async {
    final at = DateTime.now().add(after);
    await _schedule(
      id: _testNotificationId,
      at: at,
      title: 'Nhắc nhở thử',
      body: 'Thông báo được đặt lịch từ trước, app không cần đang mở',
    );
    return at;
  }

  /// Đặt lịch theo giờ Việt Nam. Có quyền báo thức chính xác thì dùng exact,
  /// không có thì dùng inexact (Android có thể trễ vài phút để tiết kiệm pin).
  static Future<void> _schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
  }) async {
    await init();
    // Đổi DateTime của máy sang TZDateTime múi giờ Asia/Ho_Chi_Minh (giữ đúng thời điểm tuyệt đối)
    final scheduledDate = tz.TZDateTime.from(at, tz.local);
    final canExact = await _android?.canScheduleExactNotifications() ?? false;

    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: scheduledDate,
      notificationDetails: _details,
      androidScheduleMode: canExact
          ? AndroidScheduleMode.exactAllowWhileIdle // đúng giờ, kể cả khi máy đang ngủ (Doze)
          : AndroidScheduleMode.inexactAllowWhileIdle,
      title: title,
      body: body,
    );
  }
}
