# Task 03 — Trần Văn Hiếu

| Mục | Nội dung |
|---|---|
| Người thực hiện | **Trần Văn Hiếu** (Thành viên) |
| Nội dung | Quản lý công việc cá nhân (CRUD, upload ảnh, phân trang, kiểm tra công việc có trong kế hoạch trước khi xóa) + Admin quản lý kế hoạch (danh sách, đổi trạng thái, tìm kiếm, lọc theo ngày) |
| Làm sau task | 01 |
| Chi tiết kỹ thuật | `TASK.md` trong thư mục này |
| Tài liệu giải thích code | `docs/explain/tasks-admin-plans.md` (có sau khi code xong) |

## Việc của Hiếu khi nhận task
1. Đọc `TASK.md` để biết task gồm những chức năng gì.
2. Mở code tương ứng trong `api/` và `app/`, đọc kèm file giải thích ở trên.
3. Tự chạy lại được chức năng trên máy mình.
4. Viết phần báo cáo được giao.
5. Trả lời được các câu hỏi bên dưới mà không cần nhìn tài liệu.

## Phải giải thích được
- Mỗi API lấy UserId từ JWT và chỉ cho sửa/xóa công việc của chính chủ (tránh sửa dữ liệu người khác)
- Xóa công việc: Any() trên bảng PlanItems theo TaskId, nếu có thì chặn và báo lý do
- Chuyển trạng thái kế hoạch hợp lệ: Đã chốt, Đang thực hiện, Hoàn thành hoặc Hủy; không cho nhảy ngược
- Lọc theo ngày: from.Date <= ngày < to.Date.AddDays(1) để không sót ngày cuối
- Validate form trong Flutter (tiêu đề bắt buộc, hạn không ở quá khứ) và validate lại ở API

## Câu hỏi giảng viên có thể hỏi
- Nếu tôi đổi Id trong URL để xóa công việc của người khác thì sao?
- Vì sao lọc đến ngày 30 phải cộng thêm một ngày?
- Trạng thái kế hoạch được phép đổi theo thứ tự nào? Code kiểm tra ở đâu?
- Xóa công việc đang nằm trong kế hoạch, bạn chọn chặn hay xóa lan? Vì sao?

## Phần báo cáo phụ trách
2.4.6 (Quản lý công việc), 2.4.9 (Admin quản lý kế hoạch), bảng Tasks ở 4.2, sơ đồ trạng thái Công việc (3.2.1), màn hình công việc và Admin kế hoạch ở 6.2
