# Task 01 — Nền tảng + Xác thực, phân quyền (Giang)

## Mục tiêu
Dựng khung chạy được cho cả nhóm và hoàn thành nhóm Xác thực (trừ OTP email và Google).

## Checklist
### Khung dự án
- [ ] `api/`: solution `TaskReminder.sln`, project `TaskReminder.Api` (.NET 10, Web API controllers). Package: EF Core SqlServer, JwtBearer, BCrypt.Net-Next.
- [ ] Cấu trúc thư mục đúng CLAUDE.md; `ApiResponse<T>`, `PagedResult<T>`, middleware bắt lỗi trả response chuẩn.
- [ ] `AppDbContext` + entity cho TẤT CẢ bảng trong `db/01_schema.sql` (để các bạn khác dùng ngay), ánh xạ đúng tên bảng/cột.
- [ ] `FileService` dùng chung: lưu ảnh vào `wwwroot/uploads/<folder>`, kiểm tra đuôi và dung lượng, xóa file theo url.
- [ ] `appsettings.Development.example.json`, CORS, static files, Swagger hoặc OpenAPI, file `.http`.
- [ ] Seed tài khoản admin/member bằng BCrypt (xem `db/02_seed.sql`).
- [ ] `app/`: `flutter create` với org `vn.edu.hcmunre`, tên `task_reminder`, chỉ Android + Windows nếu cần. Package: dio, provider, sqflite, path, image_picker, intl, flutter_local_notifications, timezone.
- [ ] `core/config.dart`, `core/api_client.dart` (interceptor gắn Bearer token, 401 thì xóa phiên và về màn đăng nhập), `core/local_db.dart` tạo bảng `session` và `plan_draft`.
- [ ] Điều hướng: Splash kiểm tra phiên trong SQLite → Login hoặc Home. Bottom navigation: Trang chủ, Công việc, Kế hoạch (badge), Tài khoản; mục Quản trị chỉ hiện với Admin.
- [ ] Màn hình placeholder cho các module của Bảo, Hiếu, An để họ điền vào.

### Xác thực
- [ ] API: register, login, change-password, me (xem docs/API.md). Login chặn tài khoản bị khóa và `EmailConfirmed=0` (tạm thời: có cờ cấu hình `RequireEmailConfirmation` để tắt khi An chưa làm xong OTP).
- [ ] API: users (danh sách, tìm kiếm, phân trang), đổi role, khóa/mở khóa; không cho tự hạ quyền/tự khóa.
- [ ] Flutter: màn Đăng ký, Đăng nhập, Đổi mật khẩu, Tài khoản (đăng xuất), Admin: Quản lý member (đổi role, khóa).
- [ ] Validate form ở cả app và API.

## Hoàn thành khi
`dotnet build` và `flutter analyze` sạch; đăng nhập admin thấy menu Quản trị, member thì không; gọi API Admin bằng token member trả 403. Viết `docs/explain/auth.md`.
