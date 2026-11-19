# Task 01 — Phạm Minh Giang

| Mục | Nội dung |
|---|---|
| Người thực hiện | **Phạm Minh Giang** (Nhóm trưởng) |
| Nội dung | Khung dự án (API .NET 10, app Flutter, SQLite, entity cho tất cả bảng, FileService) + đăng ký, đăng nhập, đổi mật khẩu, đăng xuất, quản lý member và role, phân quyền |
| Làm sau task | Làm đầu tiên |
| Chi tiết kỹ thuật | `TASK.md` trong thư mục này |
| Tài liệu giải thích code | `docs/explain/auth.md` (có sau khi code xong) |

## Việc của Giang khi nhận task
1. Đọc `TASK.md` để biết task gồm những chức năng gì.
2. Mở code tương ứng trong `api/` và `app/`, đọc kèm file giải thích ở trên.
3. Tự chạy lại được chức năng trên máy mình.
4. Viết phần báo cáo được giao.
5. Trả lời được các câu hỏi bên dưới mà không cần nhìn tài liệu.

## Phải giải thích được
- Băm mật khẩu bằng BCrypt: có salt, không giải ngược được, khác với mã hóa
- Cấu trúc JWT (header.payload.signature), claim role, thời hạn token, API xác thực token ra sao
- Phân quyền hai lớp: API chặn bằng [Authorize(Roles="Admin")], Flutter chỉ ẩn menu cho đẹp
- Đăng xuất phía client: xóa phiên đăng nhập (token) trong SQLite, vì sao không cần gọi server
- Đăng nhập Google: app lấy idToken, API xác minh rồi cấp JWT của hệ thống

## Câu hỏi giảng viên có thể hỏi
- Băm khác mã hóa chỗ nào? Quên mật khẩu thì có xem lại được mật khẩu cũ không?
- Token hết hạn thì app xử lý thế nào?
- Nếu chỉ ẩn nút Admin trên Flutter mà API không kiểm tra role thì sao?
- Đổi mật khẩu kiểm tra mật khẩu cũ bằng cách nào?

## Phần báo cáo phụ trách
Chương I (1.1, 1.2), 2.1 đến 2.3 (tổng hợp), 2.4.1 đến 2.4.4, Chương V (kiến trúc, framework), 7.1, 7.2, 7.3 và gộp toàn bộ báo cáo
