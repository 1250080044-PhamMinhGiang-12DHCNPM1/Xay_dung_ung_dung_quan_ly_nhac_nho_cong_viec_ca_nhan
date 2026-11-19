# Task 02 — Trương Gia Bảo

| Mục | Nội dung |
|---|---|
| Người thực hiện | **Trương Gia Bảo** (Thành viên) |
| Nội dung | Quản lý nhóm công việc (Admin, upload ảnh thêm/sửa/xóa, kiểm tra trước khi xóa) + Trang chủ (mới nhất, theo nhóm, tìm kiếm, chi tiết, liên quan, đều có phân trang) |
| Làm sau task | 01 |
| Chi tiết kỹ thuật | `TASK.md` trong thư mục này |
| Tài liệu giải thích code | `docs/explain/category-home.md` (có sau khi code xong) |

## Việc của Bảo khi nhận task
1. Đọc `TASK.md` để biết task gồm những chức năng gì.
2. Mở code tương ứng trong `api/` và `app/`, đọc kèm file giải thích ở trên.
3. Tự chạy lại được chức năng trên máy mình.
4. Viết phần báo cáo được giao.
5. Trả lời được các câu hỏi bên dưới mà không cần nhìn tài liệu.

## Phải giải thích được
- Phân trang: Skip((page-1)*pageSize).Take(pageSize), tổng trang = Ceiling(tổng/pageSize); Flutter cuộn đến cuối thì tải trang kế
- Upload file: multipart/form-data, IFormFile, kiểm tra đuôi và dung lượng, đặt tên file bằng Guid, lưu vào wwwroot/uploads
- Sửa ảnh: có ảnh mới thì xóa ảnh cũ trên đĩa; xóa nhóm thì xóa ảnh kèm theo
- Ràng buộc xóa: nhóm còn công việc thì API trả 409 Conflict và app hiển thị thông báo
- Công việc liên quan: cùng nhóm, khác Id hiện tại, có phân trang

## Câu hỏi giảng viên có thể hỏi
- Phân trang tính như thế nào, trang cuối còn lẻ thì sao?
- Sửa nhóm mà chọn ảnh mới, ảnh cũ nằm đâu? Bạn xử lý ra sao?
- Vì sao đặt tên file bằng Guid chứ không giữ tên gốc?
- Kiểm tra ràng buộc khi xóa nằm ở client hay server? Vì sao?

## Phần báo cáo phụ trách
2.4.5 (Quản lý nhóm), use case Trang chủ, bảng Categories ở 4.2, màn hình nhóm và trang chủ ở 6.2, sơ đồ tuần tự upload ảnh (3.3)
