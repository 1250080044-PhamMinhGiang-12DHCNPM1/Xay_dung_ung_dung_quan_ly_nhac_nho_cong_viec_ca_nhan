# Giải thích cho sinh viên — Task 01: Nền tảng + Xác thực, phân quyền

Người giải thích: **Phạm Minh Giang**.

## 1. Chạy thử trên máy

1. Tạo CSDL (bắt buộc `-f 65001` để sqlcmd đọc file UTF-8, nếu không tiếng Việt bị lỗi font):
   ```powershell
   sqlcmd -S localhost -E -C -f 65001 -i db/01_schema.sql
   sqlcmd -S localhost -E -C -f 65001 -i db/02_seed.sql
   ```
2. API: copy `api/TaskReminder.Api/appsettings.Development.example.json` thành `appsettings.Development.json`, sửa chuỗi kết nối và đặt `Jwt:Key` (chuỗi ngẫu nhiên ≥ 32 ký tự). Chạy:
   ```powershell
   cd api/TaskReminder.Api; dotnet run --launch-profile http
   ```
   API chạy ở `http://localhost:5080`, Swagger UI ở `http://localhost:5080/swagger`. Thử từng endpoint bằng `TaskReminder.Api.http`.
3. App: `cd app; flutter pub get; flutter run` (emulator Android gọi `http://10.0.2.2:5080`, đổi trong `lib/core/config.dart`).

Tài khoản mẫu: `admin@nhacviec.local` / `Admin@123`, `member@nhacviec.local` / `Member@123`.

## 2. Tóm tắt luồng

### Đăng ký
App (`RegisterScreen`) validate form → `AuthService.register` gọi `POST /api/auth/register` → API validate DTO (DataAnnotations) → kiểm tra email trùng (409) → băm mật khẩu bằng BCrypt → lưu `Users` với role Member, `EmailConfirmed = 0`. (Gửi OTP xác thực email là phần của An, đã chừa chỗ `TODO` trong `AuthService.RegisterAsync`.)

### Đăng nhập (lưu phiên vào SQLite)
App gọi `POST /api/auth/login` → API tìm user theo email, `BCrypt.Verify` mật khẩu → sai thì 401 "Email hoặc mật khẩu không đúng" (không nói rõ sai cái nào, tránh lộ email đã đăng ký) → bị khóa thì 403 → chưa xác thực email thì 403 (chỉ khi `Auth:RequireEmailConfirmation = true`; môi trường Development đang để `false` cho tới khi An làm xong OTP) → tạo JWT → trả `{token, expiresAt, user}`.
App lưu phiên vào bảng SQLite `session` (luôn 1 dòng, `id = 1`) qua `LocalDb.saveSession`, rồi vào Home.

### Mở app lại
`SplashScreen` → `AuthProvider.loadSession()` đọc bảng `session` → còn hạn thì vào `/home`, hết hạn hoặc không có thì xóa và vào `/login`.

### Mỗi lần gọi API
Interceptor của Dio (`core/api_client.dart`) đọc token trong SQLite và gắn header `Authorization: Bearer <token>`. API (JwtBearer) kiểm tra chữ ký, issuer, audience, hạn dùng; sau đó `OnTokenValidated` kiểm tra thêm trong DB: tài khoản bị khóa hoặc role đã đổi thì từ chối token (401) để bắt đăng nhập lại.
Khi API trả 401 cho request có gửi token → interceptor xóa phiên trong SQLite, báo `AuthProvider`, hiện thông báo và đưa về màn Đăng nhập.

### Đổi mật khẩu
`POST /api/auth/change-password` (cần đăng nhập). API lấy UserId từ claim `sub` của token (không nhận từ client), `BCrypt.Verify(oldPassword, PasswordHash)` → sai thì 400 "Mật khẩu cũ không đúng" → đúng thì băm mật khẩu mới và lưu.

### Đăng xuất
Chỉ xóa phiên trong SQLite (`LocalDb.clearSession`) rồi về `/login`, xóa hết lịch sử điều hướng. Không gọi server.

### Admin quản lý member và role
Tab **Quản trị** chỉ hiện khi `session.role == 'Admin'`. Màn `UserManagementScreen` gọi `GET /api/users?keyword&page&pageSize` (tìm theo email hoặc họ tên, phân trang, cuộn tới cuối thì tải trang tiếp), `PUT /api/users/{id}/role`, `PUT /api/users/{id}/lock`. API không cho Admin tự hạ quyền hoặc tự khóa chính mình (400). Toàn bộ controller có `[Authorize(Roles = "Admin")]`, nên token Member gọi vào nhận 403.

## 3. File nào làm gì

### API (`api/TaskReminder.Api`)
| File | Vai trò |
|---|---|
| `Program.cs` | Đăng ký DbContext, service, JWT, CORS, OpenAPI/Swagger UI, static files, middleware; gọi seeder khi khởi động |
| `Common/ApiResponse.cs` | Response chuẩn `{success, message, data}` |
| `Common/PagedResult.cs` | `PagedResult<T>` + hàm `ToPagedResultAsync` (Skip/Take) cho mọi module |
| `Common/AppException.cs` | Lỗi nghiệp vụ kèm mã HTTP (400/403/404/409) |
| `Common/ErrorHandlingMiddleware.cs` | Bắt exception, trả response chuẩn; lỗi lạ trả 500 và ghi log |
| `Common/ClaimsExtensions.cs` | `User.GetUserId()` lấy Id từ claim `sub` (Bảo, Hiếu, An dùng lại) |
| `Data/AppDbContext.cs` | Ánh xạ 7 bảng đúng tên bảng/cột trong `db/01_schema.sql`; quy ước giờ UTC |
| `Data/Entities/*.cs` | Entity cho TẤT CẢ bảng: Role, User, EmailOtp, Category, TaskItem, Plan, PlanItem |
| `Data/DbSeeder.cs` | Bảo đảm có 2 role và 2 tài khoản mẫu với hash BCrypt thật |
| `DTOs/AuthDtos.cs`, `DTOs/UserDtos.cs` | Request/response + quy tắc validate |
| `Services/AuthService.cs` | Đăng ký, đăng nhập, đổi mật khẩu, `me`, tạo JWT (`CreateLoginResponse` để task 05 dùng lại) |
| `Services/UserService.cs` | Danh sách/tìm kiếm member, đổi role, khóa/mở khóa |
| `Services/FileService.cs` | Lưu/xóa ảnh dùng chung (đuôi jpg/jpeg/png/webp, tối đa 5 MB, tên Guid, chống path traversal) |
| `Controllers/AuthController.cs` | `/api/auth/register`, `login`, `me`, `change-password` |
| `Controllers/UsersController.cs` | `/api/users`, `/api/users/{id}/role`, `/api/users/{id}/lock` (chỉ Admin) |
| `TaskReminder.Api.http` | Các request mẫu để thử, gồm cả trường hợp lỗi 400/401/403 |
| `appsettings.Development.example.json` | Mẫu cấu hình bí mật (file thật đã gitignore) |

### App (`app/lib`)
| File | Vai trò |
|---|---|
| `main.dart` | Đăng ký Provider, route, `navigatorKey` cho interceptor |
| `core/config.dart` | `baseUrl` của API, hàm ghép url ảnh |
| `core/api_client.dart` | Dio + interceptor gắn token, xử lý 401; `ApiClient.send` trả `data` hoặc ném `ApiException` |
| `core/local_db.dart` | SQLite `task_reminder.db`: tạo bảng `session`, `plan_draft`; lưu/đọc/xóa phiên |
| `core/validators.dart` | Validate form phía app (cùng quy tắc với DTO của API) |
| `core/theme.dart` | Theme Material 3 |
| `models/session.dart`, `models/user.dart`, `models/paged_result.dart` | Model + chuyển đổi JSON/SQLite |
| `services/auth_service.dart`, `services/user_service.dart` | Gọi API auth và users |
| `providers/auth_provider.dart` | Phiên hiện tại, `isAdmin`, login/logout |
| `providers/plan_draft_provider.dart` | Số mục kế hoạch nháp cho badge (An hoàn thiện) |
| `screens/splash_screen.dart` | Kiểm tra phiên → Login hoặc Home |
| `screens/auth/` | Đăng nhập, Đăng ký |
| `screens/home/main_shell.dart` | Bottom navigation: Trang chủ, Công việc, Kế hoạch (badge), Tài khoản, Quản trị (chỉ Admin) |
| `screens/profile/` | Tài khoản (đăng xuất), Đổi mật khẩu |
| `screens/admin/` | Menu Quản trị, Quản lý member |
| `screens/home/home_screen.dart`, `screens/task/my_tasks_screen.dart`, `screens/plan/plan_draft_screen.dart` | Màn hình tạm cho Bảo, Hiếu, An |
| `widgets/placeholder_view.dart` | Widget "Đang phát triển" dùng cho màn hình tạm |

## 4. Kiến thức cần nắm

### Băm mật khẩu bằng BCrypt
- **Băm (hash)** là hàm một chiều: từ mật khẩu ra chuỗi hash, không có cách tính ngược. **Mã hóa (encrypt)** thì có khóa để giải mã lại.
- BCrypt tự sinh **salt** ngẫu nhiên cho mỗi lần băm và gắn vào chuỗi kết quả: `$2a$11$<22 ký tự salt><31 ký tự hash>`. `11` là work factor (2^11 vòng lặp), làm việc dò mật khẩu chậm đi.
- Vì có salt, hai người cùng mật khẩu `123456` vẫn có hash khác nhau, nên không tra được bằng bảng hash có sẵn (rainbow table).
- Kiểm tra: `BCrypt.Verify(matKhauNhap, hashDangLuu)` lấy salt trong hash, băm lại mật khẩu nhập và so sánh.

### JWT
- Dạng `header.payload.signature`, mỗi phần mã hóa base64url (ai cũng đọc được payload, nên **không** để mật khẩu trong token).
- Payload của hệ thống: `sub` (Id người dùng), `email`, `name`, `role` (`Admin`/`Member`), `exp` (hết hạn), `iss`, `aud`.
- `signature = HMAC-SHA256(header + "." + payload, Jwt:Key)`. Chỉ server biết `Jwt:Key`, nên ai sửa payload (ví dụ đổi `role` thành `Admin`) thì chữ ký không khớp → 401.
- Thời hạn: `Jwt:ExpiresMinutes` (mặc định 1440 phút = 1 ngày). `ValidateLifetime = true` nên token quá `exp` bị từ chối.

### Phân quyền hai lớp
- **API (lớp thật):** `[Authorize]` yêu cầu token hợp lệ; `[Authorize(Roles = "Admin")]` yêu cầu claim `role = Admin`, sai thì 403.
- **Flutter (lớp giao diện):** ẩn tab Quản trị với Member cho gọn. Đây không phải bảo mật, vì ai cũng gọi API trực tiếp được bằng Postman.

## 5. Câu hỏi giảng viên có thể hỏi

**1. Băm khác mã hóa chỗ nào? Quên mật khẩu thì xem lại mật khẩu cũ được không?**
Mã hóa có khóa để giải ngược; băm là một chiều, không có khóa giải. Hệ thống chỉ lưu hash BCrypt nên không ai, kể cả Admin, xem được mật khẩu cũ. Quên mật khẩu thì phải đặt mật khẩu mới qua OTP email (task 04): xác minh người dùng sở hữu email, rồi lưu hash của mật khẩu mới.

**2. Token hết hạn thì app xử lý thế nào?**
Hai chỗ. (1) Khi mở app, `SplashScreen` so `expires_at` trong SQLite với giờ hiện tại, hết hạn thì xóa phiên và vào màn Đăng nhập. (2) Đang dùng mà token hết hạn (hoặc bị Admin khóa, đổi role), API trả 401, interceptor Dio xóa phiên trong SQLite, hiện thông báo và đưa về màn Đăng nhập. Người dùng đăng nhập lại để lấy token mới.

**3. Nếu chỉ ẩn nút Admin trên Flutter mà API không kiểm tra role thì sao?**
Member vẫn lấy token của mình rồi gọi thẳng `GET /api/users` hay `PUT /api/users/2/role` bằng Postman hoặc curl, tự nâng mình thành Admin. Vì vậy API mới là nơi kiểm tra thật: `UsersController` có `[Authorize(Roles = "Admin")]`, token Member gọi vào nhận 403 "Bạn không có quyền thực hiện chức năng này" (đã thử trong file `.http`).

**4. Đổi mật khẩu kiểm tra mật khẩu cũ bằng cách nào?**
API lấy UserId từ claim `sub` của token, đọc `PasswordHash` trong DB và gọi `BCrypt.Verify(oldPassword, PasswordHash)`. Sai thì 400 "Mật khẩu cũ không đúng". Đúng thì `BCrypt.HashPassword(newPassword)` (salt mới) và lưu đè.

**5. Đăng xuất sao không cần gọi server?**
JWT là token không trạng thái: server không lưu danh sách phiên, chỉ kiểm tra chữ ký và hạn dùng. Đăng xuất là xóa token khỏi SQLite; app không còn token nên không gọi được API cần đăng nhập. (Nhược điểm: ai đã copy được token thì vẫn dùng được tới khi hết hạn. Hệ thống giảm rủi ro bằng cách kiểm tra khóa/đổi role trong `OnTokenValidated`.)

**6. Admin bị khóa hoặc bị đổi role thì token cũ còn dùng được không?**
Không. Mỗi request, `OnTokenValidated` trong `Program.cs` đọc lại `IsLocked` và role trong DB. Bị khóa → 401 "Tài khoản đã bị khóa"; role khác với role trong token → 401 "Quyền đã thay đổi, vui lòng đăng nhập lại".

## 6. Ghi chú cho các thành viên khác
- Lấy UserId trong controller: `User.GetUserId()` (namespace `TaskReminder.Api.Common`). Không nhận UserId từ client.
- Lỗi nghiệp vụ: `throw new AppException(StatusCodes.Status409Conflict, "...")`, middleware tự trả response chuẩn.
- Phân trang: `query.OrderBy(...).Select(...).ToPagedResultAsync(page, pageSize)`.
- Ảnh: `FileService.SaveImageAsync(image, FileService.FolderTasks)` và `FileService.DeleteFile(url)`.
- Giờ lưu trong DB là UTC; JSON trả về có hậu tố `Z`, app gọi `.toLocal()` khi hiển thị.
- App: gọi API bằng `ApiClient.send(() => ApiClient.dio.get('/...'))`; phân trang dùng `PagedResult.fromJson(data, Model.fromJson)`.
