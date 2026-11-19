# Giải thích cho sinh viên — Task 04: Kế hoạch nháp, chốt kế hoạch, nhắc nhở, email OTP

Người giải thích: **Nguyễn Hoài An**.

## 1. Chạy thử

1. Chạy API như task 01 (`docs/explain/auth.md`).
2. Email thật: mở `api/TaskReminder.Api/appsettings.Development.json` (file này đã gitignore, KHÔNG commit), điền
   ```json
   "Smtp": { "Host": "smtp.gmail.com", "Port": 587, "User": "tai-khoan@gmail.com", "AppPassword": "16 ký tự", "FromName": "Nhắc việc" }
   ```
   `AppPassword` là **Mật khẩu ứng dụng** tạo ở Google Account → Bảo mật → Xác minh 2 bước → Mật khẩu ứng dụng (không phải mật khẩu Gmail).
   Để trống `AppPassword` thì API **không gửi mail** mà ghi nội dung email (có mã OTP) ra cửa sổ chạy API (chỉ trong môi trường Development).
3. `TaskReminder.Api.http`: phần **PLANS** và **OTP EMAIL**.
4. App: Trang chủ → chi tiết công việc → **Thêm vào kế hoạch** (badge tab Kế hoạch tăng) → tab **Kế hoạch** → chỉnh phút, chọn ngày, ghi chú → **Chốt kế hoạch**. Nút đồng hồ trên AppBar mở **Lịch sử**. Tab **Tài khoản** có **Thử thông báo ngay** và **Thử nhắc sau 1 phút**.

## 2. Luồng xử lý

### A. Kế hoạch nháp (SQLite) và chốt kế hoạch — tương đương "giỏ hàng" và "đặt hàng"
1. **Thêm:** màn chi tiết công việc (task 02) gọi `PlanDraftProvider.addToPlan(task)` → `PlanDraftRepository.add` kiểm tra `task_id` đã có trong bảng `plan_draft` chưa (có thì trả `false` = đã có), chưa có thì `INSERT` với 30 phút mặc định → provider đọc lại danh sách → `notifyListeners()` → **badge cập nhật ngay**.
2. **Sửa / xóa:** nút −/+ đổi 15 phút một lần (15 → 480) bằng `UPDATE plan_draft SET minutes`, thùng rác hoặc vuốt sang trái để `DELETE`. Mỗi thao tác đều ghi SQLite rồi `notifyListeners()`.
3. **Mở lại app:** `SplashScreen` gọi `refreshCount()` → `load()` đọc lại bảng `plan_draft` → nháp vẫn còn, badge đúng.
4. **Chốt:** `PlanService.create` gửi `POST /api/plans {planDate, note, items:[{taskId, minutes}]}` → API trong **1 transaction**: kiểm tra mọi taskId thuộc người dùng → `INSERT Plans` → `INSERT PlanItems` → `Commit`. Thành công → app `DELETE FROM plan_draft` (badge về 0) → mở **Chi tiết kế hoạch**.
5. **Lịch sử:** `GET /api/plans?keyword&page&pageSize` (tìm theo ghi chú hoặc tên công việc, debounce 400 ms, cuộn vô hạn). **Chi tiết:** `GET /api/plans/{id}` (kế hoạch người khác → 404).

### B. Nhắc nhở
1. `main.dart` gọi `NotificationService.init()`: nạp dữ liệu múi giờ, đặt `Asia/Ho_Chi_Minh`, khởi tạo plugin.
2. Vào màn chính (`MainShell`) → `requestPermissions()`: hộp thoại cho phép thông báo (Android 13+); chưa có quyền báo thức chính xác thì mở trang cài đặt **1 lần**.
3. Form công việc (task 03) lưu xong gọi `cancelTaskReminder(id)` rồi `scheduleTaskReminder(task)`; xóa công việc gọi `cancelTaskReminder(id)`. **ID thông báo = TaskId** nên hủy/đặt lại rất đơn giản.
4. `scheduleTaskReminder`: bỏ qua nếu `reminderAt` null hoặc đã qua; đổi sang `TZDateTime` giờ Việt Nam; `zonedSchedule` với `exactAllowWhileIdle` (có quyền) hoặc `inexactAllowWhileIdle` (không có quyền, có thể trễ vài phút).

### C. Email OTP
- **Đăng ký:** tạo user (`EmailConfirmed = 0`) → `OtpService.CreateAndSendAsync(VerifyEmail)` → app mở **màn nhập OTP** → `POST /api/auth/verify-email` → `EmailConfirmed = 1`.
- **Gửi lại:** `POST /api/auth/resend-otp` (nút có đếm ngược 60 giây, API cũng chặn < 60 giây).
- **Quên mật khẩu:** màn đăng nhập → **Quên mật khẩu?** → `POST /api/auth/forgot-password` (luôn báo thành công) → màn **Đặt mật khẩu mới** → `POST /api/auth/reset-password {email, code, newPassword}` → về đăng nhập, điền sẵn email.
- **Đăng nhập khi chưa xác thực** (khi bật `Auth:RequireEmailConfirmation = true`): API trả 403 → app hỏi "Nhập mã" → màn nhập OTP (cho gửi lại mã ngay).

## 3. File nào làm gì

### API
| File | Vai trò |
|---|---|
| `DTOs/PlanDtos.cs` | `CreatePlanRequest` (+ validate), `PlanSummaryDto`, `PlanDetailDto`, `PlanItemDto` |
| `Services/PlanService.cs` | Chốt kế hoạch trong transaction, lịch sử (tìm kiếm, phân trang), chi tiết |
| `Controllers/PlansController.cs` | `POST /api/plans`, `GET /api/plans`, `GET /api/plans/{id}` |
| `Services/EmailService.cs` | Gửi mail SMTP Gmail (App Password), mẫu email OTP HTML tiếng Việt; chưa cấu hình thì ghi log (Development) |
| `Services/OtpService.cs` | Sinh OTP bằng `RandomNumberGenerator`, lưu bản băm BCrypt, hết hạn 5 phút, 1 lần, sai 5 lần hủy, gửi lại 60 giây |
| `Services/AuthService.cs` | Register gửi OTP; `VerifyEmailAsync`, `ResendOtpAsync`, `ForgotPasswordAsync`, `ResetPasswordAsync` |
| `Controllers/AuthController.cs` | `verify-email`, `resend-otp`, `forgot-password`, `reset-password` |
| `DTOs/AuthDtos.cs` | Request OTP (+ validate mã 6 số, purpose) |

### App
| File | Vai trò |
|---|---|
| `services/plan_draft_repository.dart` | CRUD SQLite bảng `plan_draft` |
| `providers/plan_draft_provider.dart` | Danh sách nháp trong bộ nhớ, `addToPlan`, đổi phút, xóa, xóa hết, badge |
| `models/plan_draft_item.dart`, `models/plan.dart` | Model nháp và kế hoạch |
| `services/plan_service.dart` | Gọi `/api/plans` |
| `screens/plan/plan_draft_screen.dart` | Màn nháp: stepper 15 phút, xóa, tổng, ngày, ghi chú, chốt |
| `screens/plan/plan_history_screen.dart`, `plan_detail_screen.dart` | Lịch sử và chi tiết kế hoạch |
| `services/notification_service.dart` | Thông báo cục bộ: init timezone, xin quyền, đặt/hủy lịch theo TaskId, thông báo thử |
| `android/app/src/main/AndroidManifest.xml` | Quyền `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED`; 2 receiver của plugin |
| `screens/profile/profile_screen.dart` | Nút "Thử thông báo ngay", "Thử nhắc sau 1 phút" |
| `screens/auth/verify_email_screen.dart` | Nhập OTP xác thực email |
| `screens/auth/forgot_password_screen.dart`, `reset_password_screen.dart` | Quên mật khẩu, đặt mật khẩu mới |
| `widgets/resend_otp_button.dart` | Nút "Gửi lại mã" đếm ngược 60 giây |
| `core/formatters.dart` | `formatMinutes(90)` → "1 giờ 30 phút" |

## 4. Vì sao kế hoạch nháp lưu SQLite?
- Nháp là **dữ liệu tạm của riêng máy** (giống giỏ hàng chưa thanh toán): chưa cần server biết, chưa có giá trị nghiệp vụ.
- **Tắt app mở lại vẫn còn** vì nằm trong file `task_reminder.db` trên điện thoại (bộ nhớ RAM thì mất khi tắt app).
- **Nhanh, không tốn mạng**: thêm/bớt/đổi phút liên tục không phải gọi API mỗi lần; dùng được cả khi mất mạng.
- Chỉ khi **Chốt** mới gửi 1 request lên API → server lưu thành kế hoạch chính thức (bảng `Plans`, `PlanItems`) để Admin quản lý.

## 5. Transaction để làm gì?
Chốt kế hoạch phải ghi **nhiều bảng**: 1 dòng `Plans` + n dòng `PlanItems`. Không có transaction, nếu đã ghi `Plans` mà lỗi khi ghi `PlanItems` (mất kết nối, vi phạm ràng buộc...) thì CSDL còn **kế hoạch thiếu công việc**.
```csharp
await using var transaction = await _db.Database.BeginTransactionAsync();
// kiểm tra quyền sở hữu taskId → INSERT Plans (SaveChanges, có plan.Id) → INSERT PlanItems (SaveChanges)
await transaction.CommitAsync();   // chỉ tới đây dữ liệu mới thật sự "chốt"
```
Có exception ở bất kỳ bước nào thì không chạy tới `CommitAsync`; `await using` hủy transaction → **ROLLBACK**, dòng `Plans` đã ghi cũng bị hoàn tác. Đây là tính **nguyên tử** (Atomicity) trong ACID: "tất cả hoặc không gì cả".
Kiểm tra `taskId` thuộc người dùng nằm ngay đầu transaction: gửi taskId của người khác → 400, **không tạo bản ghi nào** (đã thử: số dòng Plans/PlanItems không đổi).

## 6. Cơ chế thông báo khi app tắt
- `zonedSchedule` **không** dùng Timer trong app (Timer chết khi app tắt). Plugin đăng ký lịch với **AlarmManager của hệ điều hành Android**.
- Đến giờ, Android đánh thức và gọi `ScheduledNotificationReceiver` (khai báo trong `AndroidManifest.xml`) → receiver hiện thông báo. App không cần đang mở.
- Khởi động lại máy làm mất lịch trong AlarmManager → `ScheduledNotificationBootReceiver` (nghe `BOOT_COMPLETED`) đặt lại các lịch đã lưu.
- `exactAllowWhileIdle`: đúng giờ cả khi máy ở chế độ ngủ (Doze); cần quyền "Báo thức và lời nhắc" (Android 12+). Không có quyền → `inexactAllowWhileIdle`, Android có thể gom và trễ vài phút để tiết kiệm pin.
- Đã thử trên emulator: đặt "Thử nhắc sau 1 phút", diệt hẳn tiến trình app (pid không còn), đến giờ Android tự chạy receiver và thông báo hiện ra. Lưu ý: **Force stop** trong Cài đặt thì Android xóa luôn lịch của app (thiết kế của Android); vuốt tắt app bình thường thì không sao.

## 7. Vì sao băm OTP?
- Lưu mã gốc thì ai đọc được CSDL (lộ backup, SQL injection, người quản trị) sẽ dùng được mã để chiếm tài khoản / đặt lại mật khẩu.
- Lưu **bản băm BCrypt** (`EmailOtps.CodeHash`): không giải ngược được; kiểm tra bằng `BCrypt.Verify(maNhap, CodeHash)`.
- Mã chỉ có 1.000.000 khả năng nên còn thêm: **hết hạn 5 phút**, **sai 5 lần thì hủy** (chống dò thử), **dùng 1 lần** (`UsedAt`), **gửi lại cách 60 giây** (chống spam mail). Sinh bằng `RandomNumberGenerator` (ngẫu nhiên an toàn cho mật mã) thay vì `Random` (đoán được chuỗi số).
- `forgot-password` luôn trả thành công để không lộ email nào đã đăng ký.

## 8. Câu hỏi giảng viên có thể hỏi

**1. Vì sao kế hoạch nháp lưu SQLite mà không gọi API ngay?**
Nháp là dữ liệu tạm của riêng điện thoại (như giỏ hàng). Lưu SQLite thì tắt app vẫn còn, thao tác nhanh, không tốn request, chạy được khi mất mạng. Chỉ khi chốt mới gửi 1 lần lên API để thành kế hoạch chính thức.

**2. Transaction trong POST /plans để làm gì? Nếu bỏ đi thì sao?**
Để ghi `Plans` và `PlanItems` theo kiểu "tất cả hoặc không gì cả". Bỏ transaction, nếu lỗi sau khi đã ghi `Plans` thì còn lại kế hoạch không có công việc, TotalMinutes sai. Có transaction thì lỗi → rollback toàn bộ.

**3. Người dùng gửi taskId của người khác lên POST /plans thì sao?**
API đếm số công việc có `Id` trong danh sách **và** `UserId` = người đang đăng nhập (lấy từ JWT). Đếm ít hơn số taskId gửi lên → 400 "Có công việc không tồn tại hoặc không thuộc về bạn", không tạo gì. `TotalMinutes` cũng do server tự cộng, không tin số client gửi.

**4. App đã tắt thì làm sao vẫn hiện thông báo nhắc?**
Lịch được giao cho AlarmManager của Android (qua `zonedSchedule`), không chạy trong app. Đến giờ Android gọi `ScheduledNotificationReceiver` đã khai báo trong manifest để hiện thông báo. Khởi động lại máy thì `ScheduledNotificationBootReceiver` đặt lại lịch.

**5. Sửa giờ nhắc hoặc xóa công việc thì thông báo cũ xử lý thế nào?**
ID thông báo = TaskId. Lưu công việc: `cancel(taskId)` rồi `schedule` lại theo giờ mới; xóa công việc: `cancel(taskId)`. Giờ nhắc đã qua thì không đặt.

**6. Vì sao lưu bản băm của OTP? Sai 5 lần, hết hạn, gửi lại 60 giây để làm gì?**
Lộ CSDL cũng không dùng được mã. Mã 6 số dễ dò nên giới hạn 5 lần sai (hủy mã), hết hạn sau 5 phút, dùng 1 lần; gửi lại cách 60 giây để chống spam email. Sinh mã bằng `RandomNumberGenerator` để không đoán trước được.

**(Thêm) Vì sao forgot-password luôn trả thành công?**
Nếu trả "email không tồn tại" thì kẻ xấu dò được email nào đã đăng ký (user enumeration). Luôn trả cùng một thông báo, chỉ gửi mail khi email có thật.
