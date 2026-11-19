# Đặc tả chức năng và điểm

Ký hiệu: [BB] bắt buộc, [+] điểm cộng. Cột "Người" là thành viên chịu trách nhiệm giải thích.

## 1. Xác thực người dùng — Giang (An làm phần email)
| Chức năng | Loại | Điểm | Người |
|---|---|---|---|
| Đăng ký | BB | 0.25 | Giang |
| Đăng nhập (lưu phiên vào SQLite) | BB | 0.25 | Giang |
| Đổi mật khẩu (kiểm tra mật khẩu cũ) | BB | 0.25 | Giang |
| Quản lý member (Admin: danh sách, tìm kiếm, khóa/mở khóa) | BB | 0.25 | Giang |
| Quản lý role (Admin: đổi role Member/Admin) | BB | 0.5 | Giang |
| Đăng xuất (xóa phiên trong SQLite) | BB | 0.25 | Giang |
| Phân quyền Member / Admin | BB | 0.5 | Giang |
| Xác thực email bằng OTP | + | 0.5 | An |
| Quên mật khẩu bằng OTP | + | 0.5 | An |
| Đăng nhập bằng Gmail (Google Sign-In) | + | 0.5 | Giang |
| Dùng API | | 0.75 | |

## 2. Quản lý nhóm công việc (Admin) — Bảo
| Chức năng | Loại | Điểm |
|---|---|---|
| Hiển thị nhóm | BB | 0.25 |
| Thêm nhóm | BB | 0.25 |
| Xóa nhóm | BB | 0.25 |
| Kiểm tra nhóm còn công việc trước khi xóa (trả 409) | BB | 0.25 |
| Sửa nhóm | BB | 0.25 |
| Upload ảnh nhóm ở cả 3 trường hợp: thêm, sửa (xóa ảnh cũ), xóa (xóa ảnh) | + | 0.75 |
| Dùng API | | 0.5 |

## 3. Quản lý công việc — Hiếu
| Chức năng | Loại | Điểm |
|---|---|---|
| Hiển thị công việc của tôi có phân trang | BB | 0.5 |
| Thêm công việc (bắt buộc hỗ trợ upload ảnh) | BB | 0.5 |
| Xóa công việc (xóa ảnh kèm theo) | BB | 0.5 |
| Sửa công việc (ảnh mới thì xóa ảnh cũ) | BB | 0.5 |
| Kiểm tra công việc có trong kế hoạch trước khi xóa | + | 0.5 |
| Dùng API | | 0.75 |
Ràng buộc: người dùng chỉ thao tác trên công việc của chính mình (UserId lấy từ JWT).

## 4. Trang chủ — Bảo
| Chức năng | Loại | Điểm |
|---|---|---|
| Hiển thị danh sách nhóm công việc | BB | 0.25 |
| Công việc mới nhất có phân trang | BB | 0.5 |
| Công việc theo nhóm (+ phân trang) | BB | 0.25 + 0.25 |
| Tìm kiếm công việc (+ phân trang) | BB | 0.25 + 0.25 |
| Chi tiết công việc | BB | 0.25 |
| Công việc liên quan (cùng nhóm, + phân trang) | + | 0.25 + 0.25 |
| Dùng API | | 0.5 |
Trang chủ chỉ hiển thị công việc của người dùng đang đăng nhập.

## 5. Kế hoạch trong ngày (giỏ hàng) — An
| Chức năng | Loại | Điểm |
|---|---|---|
| Nút "Thêm vào kế hoạch" | BB | 0.25 |
| Thêm công việc vào kế hoạch nháp (SQLite) | BB | 0.25 |
| Hiển thị số mục trên icon kế hoạch (badge) | BB | 0.25 |
| Hiển thị kế hoạch nháp | BB | 0.25 |
| Cập nhật thời lượng dự kiến (phút) — tương đương số lượng | BB | 0.5 |
| Xóa công việc khỏi kế hoạch nháp | BB | 0.25 |
| Chốt kế hoạch (checkout, transaction phía API) | BB | 0.5 |
| Chi tiết kế hoạch đã chốt | BB | 0.25 |
| Tìm kiếm kế hoạch của tôi | + | 0.25 |
| Dùng API | | 1.0 |

## 6. Quản lý kế hoạch (Admin) — Hiếu
| Chức năng | Loại | Điểm |
|---|---|---|
| Danh sách kế hoạch của mọi người dùng (phân trang) | BB | 0.25 |
| Cập nhật trạng thái kế hoạch | BB | 0.5 |
| Tìm kiếm kế hoạch | + | 0.25 |
| Lọc kế hoạch theo ngày (from, to) | + | 0.25 |
| Dùng API | | 0.25 |
Trạng thái kế hoạch: `Confirmed` → `InProgress` → `Completed`; `Confirmed`/`InProgress` → `Cancelled`. Không cho chuyển ngược.

## 7. Chức năng đặc thù đề tài (giải trình điểm tương đương) — An
- Đặt nhắc nhở cho công việc theo `ReminderAt` bằng `flutter_local_notifications` (zonedSchedule).
- Sửa giờ nhắc hoặc xóa công việc thì hủy lịch cũ. ID thông báo = TaskId.
- Xin quyền thông báo (Android 13+) và quyền exact alarm nếu cần.

## Không làm
Đăng nhập Facebook/Zalo, thanh toán VNPay/VietQR.
