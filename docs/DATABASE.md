# Thiết kế dữ liệu

Script SQL Server: `db/01_schema.sql`, dữ liệu mẫu: `db/02_seed.sql`. EF Core ánh xạ đúng tên bảng và cột dưới đây (không dùng migration tự đổi tên).

## SQL Server
| Bảng | Cột chính | Người |
|---|---|---|
| Roles | Id, Name (Admin, Member) | Giang |
| Users | Id, Email (unique), PasswordHash (null nếu chỉ đăng nhập Google), FullName, AvatarUrl, RoleId, IsLocked, EmailConfirmed, GoogleId, CreatedAt | Giang |
| EmailOtps | Id, UserId, CodeHash, Purpose (VerifyEmail, ResetPassword), ExpiresAt, UsedAt, Attempts, CreatedAt | An |
| Categories | Id, Name (unique), Description, ImageUrl, CreatedAt | Bảo |
| Tasks | Id, UserId, CategoryId, Title, Description, DueDate, Priority (1 thấp, 2 vừa, 3 cao), Status (Todo, Doing, Done), ImageUrl, ReminderAt, CreatedAt, UpdatedAt | Hiếu |
| Plans | Id, UserId, PlanDate, Status, TotalMinutes, Note, CreatedAt | An / Hiếu |
| PlanItems | Id, PlanId, TaskId, Minutes | An |

Quan hệ: Roles 1-n Users; Users 1-n Tasks; Categories 1-n Tasks (ON DELETE NO ACTION, kiểm tra trước khi xóa); Users 1-n Plans; Plans 1-n PlanItems (CASCADE); Tasks 1-n PlanItems (NO ACTION, kiểm tra trước khi xóa).

## SQLite trên điện thoại (`app/lib/core/local_db.dart`, file `task_reminder.db`)
| Bảng | Cột | Mục đích | Người |
|---|---|---|---|
| session | id (luôn = 1), user_id, email, full_name, role, token, expires_at | Phiên đăng nhập | Giang |
| plan_draft | task_id (PK), title, image_url, minutes, added_at | Kế hoạch nháp (giỏ hàng) | An |
