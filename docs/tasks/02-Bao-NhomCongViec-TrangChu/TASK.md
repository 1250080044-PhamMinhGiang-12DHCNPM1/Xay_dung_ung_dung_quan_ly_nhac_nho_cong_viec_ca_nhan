# Task 02 — Nhóm công việc (Admin) + Trang chủ (Bảo)

## Checklist
### Nhóm công việc
- [ ] `CategoriesController` + `CategoryService` theo docs/API.md, dùng `FileService` có sẵn.
- [ ] Thêm có ảnh; sửa có ảnh mới thì xóa ảnh cũ; xóa nhóm thì xóa ảnh; còn công việc thì trả 409 kèm thông báo số công việc.
- [ ] Flutter Admin: danh sách nhóm (ảnh, tên, số công việc), form thêm/sửa có chọn ảnh, xác nhận trước khi xóa, hiển thị lỗi 409.
### Trang chủ
- [ ] `HomeController`: latest, tasks (lọc theo nhóm + keyword), chi tiết, related — tất cả có phân trang.
- [ ] Flutter: Trang chủ gồm dải nhóm cuộn ngang, danh sách công việc mới nhất cuộn vô hạn (tải trang kế khi gần cuối).
- [ ] Màn công việc theo nhóm, màn tìm kiếm (debounce 400 ms), màn chi tiết có phần "Công việc liên quan" phân trang và nút "Thêm vào kế hoạch" (gọi hàm của An, tạm để stub nếu An chưa xong).
## Hoàn thành khi
Upload/sửa/xóa ảnh kiểm tra được trong `wwwroot/uploads/categories`; phân trang đúng với 25 công việc mẫu. Viết `docs/explain/category-home.md` (giải thích công thức phân trang, multipart, xóa ảnh cũ).
