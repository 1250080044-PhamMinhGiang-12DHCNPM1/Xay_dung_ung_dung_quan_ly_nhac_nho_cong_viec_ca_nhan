# Task 03 — Công việc cá nhân + Admin quản lý kế hoạch (Hiếu)

## Checklist
### Công việc
- [ ] `TasksController` + `TaskService`: CRUD theo docs/API.md, UserId lấy từ JWT, sai chủ trả 404.
- [ ] Ảnh: thêm, thay (xóa ảnh cũ), `removeImage`, xóa công việc thì xóa ảnh.
- [ ] Xóa: nếu TaskId có trong PlanItems trả 409 "Công việc đang nằm trong kế hoạch".
- [ ] Flutter: màn Công việc của tôi (phân trang, lọc trạng thái, đổi nhanh trạng thái), form thêm/sửa (tiêu đề bắt buộc, chọn nhóm, hạn, ưu tiên, giờ nhắc, ảnh).
- [ ] Sau khi lưu/xóa, gọi `NotificationService` của An để đặt/hủy nhắc (stub nếu An chưa xong).
### Admin kế hoạch
- [ ] `AdminPlansController`: danh sách (keyword, status, from, to, phân trang), đổi trạng thái theo bảng chuyển hợp lệ trong SPEC mục 6.
- [ ] Lọc ngày bao gồm cả ngày `to` (so sánh trên kiểu DATE hoặc `< to + 1 ngày`).
- [ ] Flutter Admin: danh sách kế hoạch, ô tìm kiếm, chọn khoảng ngày (`showDateRangePicker`), chip trạng thái, nút đổi trạng thái chỉ hiện trạng thái hợp lệ kế tiếp.
## Hoàn thành khi
Member A không sửa/xóa được công việc của member B; xóa công việc đã vào kế hoạch bị chặn. Viết `docs/explain/tasks-admin-plans.md`.
