# Task 04 — Kế hoạch nháp, chốt kế hoạch, nhắc nhở, email OTP (An)

## Checklist
### Kế hoạch nháp (SQLite) và chốt kế hoạch
- [ ] `PlanDraftRepository` trên bảng `plan_draft`: thêm (trùng thì báo đã có), sửa phút, xóa, đếm, xóa hết.
- [ ] `PlanDraftProvider` để badge trên icon Kế hoạch cập nhật ngay khi thêm/xóa.
- [ ] Hàm `addToPlan(task)` công khai để màn chi tiết của Bảo gọi.
- [ ] Màn Kế hoạch nháp: danh sách, chỉnh phút (stepper 15 phút), xóa, tổng thời lượng, chọn ngày và ghi chú, nút Chốt kế hoạch.
- [ ] API `POST /plans` dùng transaction (`BeginTransactionAsync`): kiểm tra task thuộc người dùng, tạo Plan, PlanItems, tính TotalMinutes; lỗi thì rollback. Chốt thành công thì app xóa nháp.
- [ ] API + màn Lịch sử kế hoạch (tìm kiếm, phân trang) và Chi tiết kế hoạch.
### Nhắc nhở
- [ ] `NotificationService`: init timezone `Asia/Ho_Chi_Minh`, xin quyền, `schedule(task)`, `cancel(taskId)`; bỏ qua thời điểm đã qua. Cấu hình AndroidManifest cần thiết.
- [ ] Nút "Thử thông báo" trong Cài đặt để demo.
### Email OTP
- [ ] `EmailService` gửi qua SMTP Gmail (App Password trong appsettings.Development.json), nội dung HTML đơn giản tiếng Việt.
- [ ] verify-email, resend-otp, forgot-password, reset-password theo docs/API.md (băm OTP, 5 phút, 1 lần, tối đa 5 lần sai, resend cách 60 giây).
- [ ] Register gửi OTP; Flutter: màn nhập OTP sau đăng ký, link "Quên mật khẩu" ở màn đăng nhập, màn đặt mật khẩu mới.
- [ ] Báo Giang bật `RequireEmailConfirmation=true` khi xong.
## Hoàn thành khi
Chốt kế hoạch tạo đúng bản ghi; tắt app vẫn nhận nhắc nhở; nhận OTP thật trong hộp thư. Viết `docs/explain/plan-reminder-email.md`.
