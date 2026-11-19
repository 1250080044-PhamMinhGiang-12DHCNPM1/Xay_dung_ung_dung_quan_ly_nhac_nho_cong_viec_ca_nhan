# Task 01 — Nền tảng + Xác thực, phân quyền (Giang)

## Mục tiêu
Dựng khung chạy được cho cả nhóm và hoàn thành nhóm Xác thực (trừ OTP email và Google).

## Checklist
### Khung dự án
- [x] `api/`: solution `TaskReminder.sln`, project `TaskReminder.Api` (.NET 10, Web API controllers). Package: EF Core SqlServer, JwtBearer, BCrypt.Net-Next.
- [x] Cấu trúc thư mục đúng CLAUDE.md; `ApiResponse<T>`, `PagedResult<T>`, middleware bắt lỗi trả response chuẩn.
- [x] `AppDbContext` + entity cho TẤT CẢ bảng trong `db/01_schema.sql` (để các bạn khác dùng ngay), ánh xạ đúng tên bảng/cột.
- [x] `FileService` dùng chung: lưu ảnh vào `wwwroot/uploads/<folder>`, kiểm tra đuôi và dung lượng, xóa file theo url.
- [x] `appsettings.Development.example.json`, CORS, static files, Swagger hoặc OpenAPI, file `.http`.
- [x] Seed tài khoản admin/member bằng BCrypt (xem `db/02_seed.sql`).
- [x] `app/`: `flutter create` với org `vn.edu.hcmunre`, tên `task_reminder`, chỉ Android + Windows nếu cần. Package: dio, provider, sqflite, path, image_picker, intl, flutter_local_notifications, timezone.
- [x] `core/config.dart`, `core/api_client.dart` (interceptor gắn Bearer token, 401 thì xóa phiên và về màn đăng nhập), `core/local_db.dart` tạo bảng `session` và `plan_draft`.
- [x] Điều hướng: Splash kiểm tra phiên trong SQLite → Login hoặc Home. Bottom navigation: Trang chủ, Công việc, Kế hoạch (badge), Tài khoản; mục Quản trị chỉ hiện với Admin.
- [x] Màn hình placeholder cho các module của Bảo, Hiếu, An để họ điền vào.

### Xác thực
- [x] API: register, login, change-password, me (xem docs/API.md). Login chặn tài khoản bị khóa và `EmailConfirmed=0` (tạm thời: có cờ cấu hình `RequireEmailConfirmation` để tắt khi An chưa làm xong OTP).
- [x] API: users (danh sách, tìm kiếm, phân trang), đổi role, khóa/mở khóa; không cho tự hạ quyền/tự khóa.
- [x] Flutter: màn Đăng ký, Đăng nhập, Đổi mật khẩu, Tài khoản (đăng xuất), Admin: Quản lý member (đổi role, khóa).
- [x] Validate form ở cả app và API.

## Hoàn thành khi
`dotnet build` và `flutter analyze` sạch; đăng nhập admin thấy menu Quản trị, member thì không; gọi API Admin bằng token member trả 403. Viết `docs/explain/auth.md`.

## Kết quả kiểm tra (19/11/2026)
- `dotnet build` sạch; `flutter analyze` không có issue; `flutter test` qua 3 test; `flutter build apk --debug` thành công.
- Đã thử bằng curl với SQL Server thật: đăng ký (201, trùng email 409, sai dữ liệu 400), đăng nhập (sai mật khẩu 401, bị khóa 403), `me`, đổi mật khẩu (sai mật khẩu cũ 400), danh sách member có tìm kiếm/phân trang, đổi role, khóa/mở khóa, tự hạ quyền/tự khóa 400, token Member gọi `/api/users` trả 403, token bị sửa trả 401, token cũ sau khi bị khóa/đổi role trả 401.
- Đã chạy trên emulator Android (API 37): Splash → Đăng nhập → Home; admin thấy tab Quản trị và danh sách member, member không thấy; đăng xuất về màn Đăng nhập; tắt app mở lại vẫn giữ phiên.
- App chỉ tạo nền tảng Android (không cần Windows).
- Ghi chú cấu hình: `compileSdk = 37` và bật core library desugaring (yêu cầu của `flutter_local_notifications` 23); `kotlin.incremental=false` để tránh lỗi cache Kotlin khi project và pub cache nằm khác ổ đĩa.
