# Task 04 — Nguyễn Hoài An

| Mục | Nội dung |
|---|---|
| Người thực hiện | **Nguyễn Hoài An** (Thành viên) |
| Nội dung | Kế hoạch nháp lưu SQLite (giỏ hàng, badge) + chốt kế hoạch (transaction) + lịch sử, tìm kiếm kế hoạch + nhắc nhở bằng thông báo cục bộ + xác thực email và quên mật khẩu bằng OTP |
| Làm sau task | 01 (phần nhắc nhở cần bảng Tasks của 03) |
| Chi tiết kỹ thuật | `TASK.md` trong thư mục này |
| Tài liệu giải thích code | `docs/explain/plan-reminder-email.md` (có sau khi code xong) |

## Việc của An khi nhận task
1. Đọc `TASK.md` để biết task gồm những chức năng gì.
2. Mở code tương ứng trong `api/` và `app/`, đọc kèm file giải thích ở trên.
3. Tự chạy lại được chức năng trên máy mình.
4. Viết phần báo cáo được giao.
5. Trả lời được các câu hỏi bên dưới mà không cần nhìn tài liệu.

## Phải giải thích được
- Kế hoạch nháp lưu trong SQLite trên máy (CRUD bằng sqflite) và chỉ gửi lên API khi chốt, chốt xong thì xóa nháp
- Chốt kế hoạch dùng transaction: tạo Plan + PlanItems, lỗi giữa chừng thì hoàn tác toàn bộ
- Tổng thời lượng = tổng Minutes các mục; badge trên icon = số mục trong bảng nháp
- Nhắc nhở: flutter_local_notifications + timezone, zonedSchedule theo ReminderAt, id thông báo = TaskId
- Sửa hoặc xóa công việc thì hủy và đặt lại lịch; không đặt lịch cho thời điểm đã qua; xin quyền thông báo Android 13+
- OTP: sinh 6 số ngẫu nhiên bằng RandomNumberGenerator, lưu bản băm, hết hạn sau 5 phút, dùng một lần; gửi bằng SMTP Gmail (App Password)
- Quên mật khẩu không tiết lộ email có tồn tại hay không; đặt lại xong thì OTP mất hiệu lực

## Câu hỏi giảng viên có thể hỏi
- Kế hoạch nháp lưu ở máy hay server? Vì sao chọn vậy? Mất mạng thì sao?
- Transaction để làm gì? Cho ví dụ khi nó cứu dữ liệu.
- App đã tắt thì thông báo nhắc vẫn hiện nhờ cơ chế nào?
- Công việc đổi giờ nhắc thì lịch cũ xử lý ra sao?
- Vì sao lưu bản băm của OTP mà không lưu nguyên mã? Ai đó đoán mã liên tục thì sao?

## Phần báo cáo phụ trách
2.4.7 (Kế hoạch trong ngày), 2.4.8 (Nhắc nhở), 2.4.10 (Xác thực email, quên mật khẩu), sơ đồ trạng thái Kế hoạch (3.2.2), sơ đồ tuần tự Chốt kế hoạch và Đặt nhắc nhở (3.3), bảng Plans/PlanItems ở 4.2 và bảng SQLite plan_draft, màn hình kế hoạch ở 6.2
