# Danh sách task

Mỗi thư mục là một task: `README.md` là phiếu giao việc để gửi cho thành viên, `TASK.md` là checklist kỹ thuật để giao cho Claude Code.
Làm lần lượt từ 01 đến 06. Mỗi task làm trên nhánh dev của người phụ trách, rồi gộp theo luồng `dev-*` → `debug` → `test` → `main`.

| Task | Nội dung | Người thực hiện | Làm sau task | Thư mục | Nhánh |
|---|---|---|---|---|---|
| 01 | Khung dự án (API .NET 10, app Flutter, SQLite, entity cho tất cả bảng, FileService) + đăng ký, đăng nhập, đổi mật khẩu, đăng xuất, quản lý member và role, phân quyền | **Phạm Minh Giang** | Làm đầu tiên | `01-Giang-NenTang-XacThuc/` | `dev-giang` |
| 02 | Quản lý nhóm công việc (Admin, upload ảnh thêm/sửa/xóa, kiểm tra trước khi xóa) + Trang chủ (mới nhất, theo nhóm, tìm kiếm, chi tiết, liên quan, đều có phân trang) | **Trương Gia Bảo** | 01 | `02-Bao-NhomCongViec-TrangChu/` | `dev-bao` |
| 03 | Quản lý công việc cá nhân (CRUD, upload ảnh, phân trang, kiểm tra công việc có trong kế hoạch trước khi xóa) + Admin quản lý kế hoạch (danh sách, đổi trạng thái, tìm kiếm, lọc theo ngày) | **Trần Văn Hiếu** | 01 | `03-Hieu-CongViec-AdminKeHoach/` | `dev-hieu` |
| 04 | Kế hoạch nháp lưu SQLite (giỏ hàng, badge) + chốt kế hoạch (transaction) + lịch sử, tìm kiếm kế hoạch + nhắc nhở bằng thông báo cục bộ + xác thực email và quên mật khẩu bằng OTP | **Nguyễn Hoài An** | 01 (phần nhắc nhở cần bảng Tasks của 03) | `04-An-KeHoach-NhacNho-Email/` | `dev-an` |
| 05 | Đăng nhập bằng Gmail (Google Sign-In) | **Phạm Minh Giang** | 01 | `05-Giang-DangNhapGoogle/` | `dev-giang` |
| 06 | Gộp code, thay stub bằng code thật, chạy thử toàn bộ luồng demo, lập checklist kiểm thử | **Phạm Minh Giang** | 02 đến 05 | `06-Giang-TichHop-KiemThu/` | `dev-giang → debug → test → main` |

## Prompt giao cho Claude Code (thay số task)
> Đọc CLAUDE.md, docs/SPEC.md, docs/API.md, docs/DATABASE.md rồi chuyển sang nhánh <nhánh-của-task> và thực hiện docs/tasks/<thư-mục-task>/TASK.md. Hỏi tôi trước nếu phải đổi bảng, cột hoặc endpoint. Xong thì đánh dấu checklist trong TASK.md, viết file giải thích ở docs/explain/ và commit.
