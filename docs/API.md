# Hợp đồng REST API (base: `/api`)

Mọi response: `{ "success": bool, "message": string, "data": ... }`.
Phân trang: query `page` (mặc định 1), `pageSize` (mặc định 10, tối đa 50); `data = { items, page, pageSize, totalItems, totalPages }`.
Mã lỗi: 400 dữ liệu sai, 401 chưa đăng nhập, 403 sai quyền hoặc tài khoản bị khóa/chưa xác thực email, 404 không tìm thấy, 409 vi phạm ràng buộc (còn dữ liệu liên quan, email trùng).
Upload: `multipart/form-data`, field ảnh tên `image`; chỉ nhận jpg, jpeg, png, webp; tối đa 5 MB; tên file = Guid. `imageUrl` trả về dạng `/uploads/<loại>/<guid>.<ext>`.

## Auth — Giang (email OTP: An)
| Method | Endpoint | Quyền | Mô tả |
|---|---|---|---|
| POST | /auth/register | Khách | `{email, password, fullName}` → tạo Member, `EmailConfirmed=0`, gửi OTP xác thực |
| POST | /auth/login | Khách | `{email, password}` → `{token, expiresAt, user{id,email,fullName,role,avatarUrl}}`; 403 nếu bị khóa hoặc chưa xác thực email |
| POST | /auth/google | Khách | `{idToken}` → xác minh với Google, tạo user nếu chưa có (`EmailConfirmed=1`), trả JWT như login |
| POST | /auth/change-password | Đăng nhập | `{oldPassword, newPassword}` |
| GET | /auth/me | Đăng nhập | Thông tin người dùng hiện tại |
| POST | /auth/verify-email | Khách | `{email, code}` (An) |
| POST | /auth/resend-otp | Khách | `{email, purpose}`; giới hạn 1 lần/60 giây (An) |
| POST | /auth/forgot-password | Khách | `{email}` → luôn trả success (không tiết lộ email có tồn tại) (An) |
| POST | /auth/reset-password | Khách | `{email, code, newPassword}` (An) |

OTP: 6 chữ số, sinh bằng `RandomNumberGenerator`, lưu bản băm, hết hạn 5 phút, dùng 1 lần, sai quá 5 lần thì hủy.

## Users (Admin) — Giang
| GET | /users?keyword&page&pageSize | Admin | Danh sách member |
| PUT | /users/{id}/role | Admin | `{role: "Admin"|"Member"}`; không cho tự hạ quyền chính mình |
| PUT | /users/{id}/lock | Admin | `{isLocked: bool}`; không cho tự khóa chính mình |

## Categories — Bảo
| GET | /categories | Đăng nhập | Tất cả nhóm (kèm `taskCount`) |
| GET | /categories/{id} | Đăng nhập | |
| POST | /categories | Admin | multipart: `name, description, image?` |
| PUT | /categories/{id} | Admin | multipart; có `image` mới thì xóa file ảnh cũ |
| DELETE | /categories/{id} | Admin | 409 nếu còn công việc; xóa file ảnh |

## Home — Bảo (chỉ công việc của người dùng hiện tại)
| GET | /home/latest?page&pageSize | Đăng nhập | Mới nhất theo CreatedAt |
| GET | /home/tasks?categoryId&keyword&page&pageSize | Đăng nhập | Theo nhóm và/hoặc tìm theo Title, Description |
| GET | /home/tasks/{id} | Đăng nhập | Chi tiết (kèm tên nhóm) |
| GET | /home/tasks/{id}/related?page&pageSize | Đăng nhập | Cùng nhóm, khác id |

## Tasks — Hiếu (chỉ của chủ sở hữu, sai chủ trả 404)
| GET | /tasks?status&page&pageSize | Đăng nhập | Công việc của tôi |
| POST | /tasks | Đăng nhập | multipart: `title, description, categoryId, dueDate, priority, status, reminderAt, image?` |
| PUT | /tasks/{id} | Đăng nhập | multipart; ảnh mới thì xóa ảnh cũ; `removeImage=true` để xóa ảnh |
| DELETE | /tasks/{id} | Đăng nhập | 409 nếu nằm trong PlanItems; xóa file ảnh |

## Plans — An
| POST | /plans | Đăng nhập | `{planDate, note, items:[{taskId, minutes}]}` → transaction tạo Plan + PlanItems; kiểm tra mọi taskId thuộc người dùng |
| GET | /plans?keyword&page&pageSize | Đăng nhập | Kế hoạch của tôi; keyword tìm theo Note hoặc Title công việc |
| GET | /plans/{id} | Đăng nhập | Chi tiết kèm danh sách công việc |

## Admin Plans — Hiếu
| GET | /admin/plans?keyword&status&from&to&page&pageSize | Admin | keyword theo email/tên người dùng hoặc Note; lọc `from <= PlanDate <= to` |
| PUT | /admin/plans/{id}/status | Admin | `{status}`; chỉ cho chuyển hợp lệ (xem SPEC mục 6) |
