# Task 04 — Kế hoạch nháp, chốt kế hoạch, nhắc nhở, email OTP (An)

## Checklist
### Kế hoạch nháp (SQLite) và chốt kế hoạch
- [x] `PlanDraftRepository` trên bảng `plan_draft`: thêm (trùng thì báo đã có), sửa phút, xóa, đếm, xóa hết.
- [x] `PlanDraftProvider` để badge trên icon Kế hoạch cập nhật ngay khi thêm/xóa.
- [x] Hàm `addToPlan(task)` công khai để màn chi tiết của Bảo gọi.
- [x] Màn Kế hoạch nháp: danh sách, chỉnh phút (stepper 15 phút), xóa, tổng thời lượng, chọn ngày và ghi chú, nút Chốt kế hoạch.
- [x] API `POST /plans` dùng transaction (`BeginTransactionAsync`): kiểm tra task thuộc người dùng, tạo Plan, PlanItems, tính TotalMinutes; lỗi thì rollback. Chốt thành công thì app xóa nháp.
- [x] API + màn Lịch sử kế hoạch (tìm kiếm, phân trang) và Chi tiết kế hoạch.
### Nhắc nhở
- [x] `NotificationService`: init timezone `Asia/Ho_Chi_Minh`, xin quyền, `schedule(task)`, `cancel(taskId)`; bỏ qua thời điểm đã qua. Cấu hình AndroidManifest cần thiết.
- [x] Nút "Thử thông báo" trong Cài đặt để demo.
### Email OTP
- [x] `EmailService` gửi qua SMTP Gmail (App Password trong appsettings.Development.json), nội dung HTML đơn giản tiếng Việt.
- [x] verify-email, resend-otp, forgot-password, reset-password theo docs/API.md (băm OTP, 5 phút, 1 lần, tối đa 5 lần sai, resend cách 60 giây).
- [x] Register gửi OTP; Flutter: màn nhập OTP sau đăng ký, link "Quên mật khẩu" ở màn đăng nhập, màn đặt mật khẩu mới.
- [x] Báo Giang bật `RequireEmailConfirmation=true` khi xong.
## Hoàn thành khi
Chốt kế hoạch tạo đúng bản ghi; tắt app vẫn nhận nhắc nhở; nhận OTP thật trong hộp thư. Viết `docs/explain/plan-reminder-email.md`.

## Kết quả kiểm tra (19/11/2026)
- `dotnet build` sạch; `flutter analyze` không có issue; `flutter test` qua.
- API Plans (curl): chốt kế hoạch tạo đúng 1 Plan (TotalMinutes = tổng phút) + PlanItems; gửi taskId của người khác hoặc không tồn tại → 400, số dòng Plans/PlanItems không đổi; items rỗng / phút = 0 / thiếu ngày → 400; taskId trùng được gộp; lịch sử tìm theo ghi chú và tên công việc; xem kế hoạch người khác → 404.
- API OTP (curl, chưa cấu hình SMTP nên mã lấy từ log): đăng ký gửi OTP; CSDL chỉ lưu hash BCrypt, hết hạn 300 giây; gửi lại < 60 giây → 400; sai 5 lần → mã bị hủy, mã đúng cũng không dùng được nữa; xác thực đúng → EmailConfirmed = 1; dùng lại mã đã dùng → 400; forgot-password với email không tồn tại vẫn trả success; reset-password → đăng nhập bằng mật khẩu cũ 401, mật khẩu mới 200.
- Emulator Android (gộp tạm với task 02 và 03):
  - Thêm vào kế hoạch từ màn chi tiết → badge 1 → 2 ngay; thêm trùng không bị thêm lần 2; diệt tiến trình app, mở lại → nháp và badge vẫn còn; +15 phút, xóa 1 mục → badge 1; chốt → Plan đúng trong CSDL (60 phút, 1 PlanItem), nháp trống, mở chi tiết; lịch sử hiển thị.
  - Hộp thoại xin quyền thông báo; "Thử thông báo ngay" hiện thông báo; "Thử nhắc sau 1 phút" → lịch nằm trong AlarmManager, diệt tiến trình app (pid rỗng) → đến giờ vẫn nhận thông báo.
  - Quên mật khẩu → đặt mật khẩu mới → đăng nhập bằng mật khẩu mới.
- Chưa thử: **nhận OTP thật trong hộp thư** (cần điền Smtp:User/AppPassword trong appsettings.Development.json); màn nhập OTP ngay sau khi đăng ký trên app (đã thử bằng API).
- `RequireEmailConfirmation` vẫn để `false` trong appsettings.Development.json — báo Giang bật `true` khi đã cấu hình gửi mail thật.
- Khi gộp: lấy bản của An cho `notification_service.dart` (task 03 là stub) và `plan_draft_provider.dart` (task 02 là stub); màn chi tiết của task 02 nên đổi thông báo khi `addToPlan` trả false thành "Công việc đã có trong kế hoạch nháp".
