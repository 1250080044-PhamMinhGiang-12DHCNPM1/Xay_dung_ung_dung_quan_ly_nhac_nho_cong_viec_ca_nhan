# Ứng dụng quản lý, nhắc nhở công việc cá nhân

Đồ án môn Lập trình đa nền tảng (Flutter) - Lớp 12_ĐH_CNPM1.
Giảng viên: ThS. Nguyễn Thanh Truyền, CN. Nguyễn Phan Chí Thành.

## Công nghệ (bắt buộc theo đề)
- App: Flutter (Dart), SQLite (sqflite) lưu dữ liệu cục bộ trên điện thoại
- API: C# ASP.NET Core .NET 10, Entity Framework Core
- CSDL phía server: SQL Server (không dùng SQLite, MongoDB, PostgreSQL cho server theo yêu cầu giảng viên)

## Cấu trúc thư mục
| Thư mục | Nội dung |
|---|---|
| `api/` | Solution .NET 10 (Controllers, Services, Repositories, DTOs) |
| `app/` | Dự án Flutter |
| `db/` | Script SQL Server (tạo bảng, dữ liệu mẫu) |
| `docs/` | Báo cáo, sơ đồ, bảng phân công |

## Thành viên và module
| Thành viên | Module |
|---|---|
| Phạm Minh Giang (nhóm trưởng) | Nền tảng, xác thực, phân quyền, đăng nhập Google |
| Trương Gia Bảo | Nhóm công việc (Admin), trang chủ |
| Trần Văn Hiếu | Công việc cá nhân, Admin quản lý kế hoạch |
| Nguyễn Hoài An | Kế hoạch trong ngày, nhắc nhở |

## Chạy dự án
1. Cài Flutter SDK, .NET 10 SDK, SQL Server. Ghi phiên bản đang dùng vào mục dưới.
2. Chạy script trong `db/` để tạo cơ sở dữ liệu.
3. API: `cd api && dotnet run` (sửa chuỗi kết nối trong `appsettings.Development.json`).
4. App: `cd app && flutter pub get && flutter run` (đặt địa chỉ API trong `lib/core/config.dart`; emulator Android dùng `10.0.2.2`).

Phiên bản: Flutter ___ | Dart ___ | .NET 10 SDK ___ | SQL Server ___

## Quy tắc làm việc nhóm
Repo: https://github.com/1250080044-PhamMinhGiang-12DHCNPM1/Xay_dung_ung_dung_quan_ly_nhac_nho_cong_viec_ca_nhan

| Nhánh | Dùng cho |
|---|---|
| `main` | Bản nộp, chỉ nhận code từ `test` |
| `dev-giang` | Task 01, 05, 06 |
| `dev-bao` | Task 02 |
| `dev-hieu` | Task 03 |
| `dev-an` | Task 04 |
| `debug` | Gộp các nhánh dev, sửa xung đột và lỗi |
| `test` | Kiểm thử toàn bộ luồng demo trước khi lên `main` |

- Luồng: `dev-*` → `debug` → `test` → `main`. Không commit thẳng vào `main`.
- Commit nhỏ và đều, thông điệp dạng `feat(task): thêm API xóa công việc`, `fix(auth): sửa kiểm tra token hết hạn`.
- Đổi cấu trúc bảng phải báo nhóm trưởng và cập nhật script trong `db/`.
- Mọi API trả cùng dạng: `{ "success": true, "message": "", "data": {} }`.
