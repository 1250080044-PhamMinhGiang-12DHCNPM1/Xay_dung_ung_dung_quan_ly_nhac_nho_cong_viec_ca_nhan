# CLAUDE.md — Hướng dẫn cho Claude Code

Đồ án môn Lập trình đa nền tảng: **Ứng dụng quản lý, nhắc nhở công việc cá nhân**. Nhóm 4 người, lớp 12_ĐH_CNPM1.
Đọc file này trước, sau đó đọc `docs/SPEC.md`, `docs/API.md`, `docs/DATABASE.md` và file `TASK.md` trong thư mục task được giao (`docs/tasks/<số>-<tên>/`).

## Công nghệ BẮT BUỘC (dùng công nghệ khác sẽ không được tính điểm)
- App: **Flutter, ngôn ngữ Dart** (thư mục `app/`).
- Lưu trữ trên điện thoại: **SQLite** qua package `sqflite` (phiên đăng nhập, kế hoạch nháp).
- Backend: **REST API C# ASP.NET Core .NET 10** (thư mục `api/`), Entity Framework Core.
- CSDL phía server: **SQL Server**. KHÔNG dùng MongoDB, PostgreSQL hay SQLite cho server.
- Không thay thế bằng Firebase, Supabase, Node.js hay bất kỳ backend nào khác.

## Bối cảnh chấm điểm
Giảng viên chấm theo bảng chức năng kiểu app bán hàng. Nhóm ánh xạ sang đề tài như sau (giữ đúng ánh xạ này trong code và giao diện):
| Yêu cầu gốc | Trong đề tài |
|---|---|
| Danh mục | Nhóm công việc (`Category`) |
| Sản phẩm | Công việc (`TaskItem`) |
| Giỏ hàng | Kế hoạch nháp trong ngày (SQLite `plan_draft`) |
| Đặt hàng (checkout) | Chốt kế hoạch (`POST /api/plans`) |
| Đơn hàng | Kế hoạch (`Plan`, `PlanItem`) |
Chức năng thêm của đề tài: nhắc nhở bằng thông báo cục bộ.
**Mọi chức năng phải đi qua REST API** (có điểm API riêng), trừ phần dữ liệu cục bộ SQLite.

## Nguyên tắc code (giảng viên yêu cầu sinh viên giải thích được code)
- Code đơn giản, rõ ràng, ưu tiên dễ hiểu hơn tối ưu. Không dùng pattern phức tạp (CQRS, MediatR, code generator, freezed...).
- Comment tiếng Việt ở các đoạn có nghiệp vụ hoặc thuật toán (phân trang, upload, transaction, OTP, phân quyền).
- Tên biến, hàm, class bằng tiếng Anh. Chuỗi hiển thị trên UI bằng tiếng Việt.
- Mỗi task kết thúc bằng phần "Giải thích cho sinh viên": tóm tắt luồng, file nào làm gì, 3 câu hỏi giảng viên có thể hỏi kèm câu trả lời. Ghi vào `docs/explain/<module>.md`.
- Không tự ý thêm chức năng ngoài SPEC. Không đổi tên bảng, cột, endpoint đã có trong `docs/API.md` và `docs/DATABASE.md`; nếu cần đổi, dừng lại và báo.

## Kiến trúc
### API (`api/TaskReminder.Api`)
```
Controllers/   nhận request, trả response chuẩn
Services/      nghiệp vụ (AuthService, CategoryService, TaskService, PlanService, EmailService, FileService)
Data/          AppDbContext, Entities/
DTOs/          request/response
Common/        ApiResponse<T>, PagedResult<T>
wwwroot/uploads/categories, wwwroot/uploads/tasks
```
- Response chuẩn: `{ "success": bool, "message": string, "data": T|null }`. Danh sách phân trang: `data = { items, page, pageSize, totalItems, totalPages }`.
- Xác thực JWT Bearer, claim `role` = `Admin` | `Member`. Endpoint Admin dùng `[Authorize(Roles = "Admin")]`.
- Mật khẩu băm bằng BCrypt (`BCrypt.Net-Next`).
- Bí mật (chuỗi kết nối, JWT key, SMTP App Password, Google ClientId) đặt trong `appsettings.Development.json` (đã gitignore). Tạo `appsettings.Development.example.json` làm mẫu.
- Bật CORS cho phát triển; phục vụ file tĩnh từ `wwwroot`.

### App (`app/`)
```
lib/
  core/      config.dart (baseUrl), api_client.dart (Dio + interceptor gắn token), local_db.dart (sqflite), theme
  models/
  services/  auth_service, category_service, task_service, plan_service, notification_service
  providers/ (Provider)
  screens/   auth/, home/, category/, task/, plan/, admin/, profile/
  widgets/
```
- State management: **Provider**. HTTP: **Dio**. Ảnh: `image_picker`. Thông báo: `flutter_local_notifications` + `timezone`.
- Emulator Android gọi API qua `http://10.0.2.2:<port>`.
- Ẩn menu Admin với Member, nhưng phân quyền thật nằm ở API.

## Git
- Nhánh: `main` (bản nộp, ổn định), `dev-giang`, `dev-bao`, `dev-hieu`, `dev-an` (phát triển theo người phụ trách), `debug` (gộp code và sửa lỗi), `test` (kiểm thử trước khi lên main).
- Task nào làm trên nhánh dev của người phụ trách: 01, 05, 06 → `dev-giang`; 02 → `dev-bao`; 03 → `dev-hieu`; 04 → `dev-an`.
- Luồng gộp: `dev-*` → `debug` (sửa xung đột, sửa lỗi) → `test` (chạy toàn bộ luồng demo) → `main`. Không commit thẳng vào `main`.
- Trước khi bắt đầu task 02–04: tạo nhánh dev từ `debug` sau khi task 01 đã được gộp vào `debug`, để có sẵn khung dự án.
- Mỗi task xong phải build/analyze sạch rồi mới commit.
- Commit nhỏ, thông điệp dạng `feat(task): ...`, `fix(auth): ...`.
- Không commit `bin/`, `obj/`, `build/`, `.dart_tool/`, file bí mật, ảnh trong `wwwroot/uploads`.

## Kiểm tra trước khi báo xong
- API: `dotnet build` không lỗi; thử endpoint bằng file `api/TaskReminder.Api/TaskReminder.Api.http`.
- App: `flutter analyze` không lỗi; chạy được trên emulator.
- Cập nhật checklist trong file task tương ứng.
