USE TaskReminderDb;
GO
INSERT INTO Roles(Name) VALUES (N'Admin'), (N'Member');
-- Mật khẩu mẫu: Admin@123 và Member@123 (hash BCrypt sinh bằng BCrypt.Net-Next, work factor 11).
-- API cũng tự seed/sửa 2 tài khoản này khi khởi động (Data/DbSeeder.cs).
-- Chạy bằng sqlcmd phải thêm -f 65001 để đọc file UTF-8, nếu không tiếng Việt sẽ bị lỗi font:
--   sqlcmd -S localhost -E -C -f 65001 -i db/02_seed.sql
INSERT INTO Users(Email, PasswordHash, FullName, RoleId, EmailConfirmed)
VALUES (N'admin@nhacviec.local', N'$2a$11$AqDnRk/niZzM3wthY38njeOfDZAZ6AIqG21PT97kLTZUgneThwYBi', N'Quản trị viên', 1, 1),
       (N'member@nhacviec.local', N'$2a$11$CfQYgh0piFD1obc7GbuAHu4dXlczT7bVaAIEf.vXEtNEnXSrI779O', N'Người dùng mẫu', 2, 1);
INSERT INTO Categories(Name, Description) VALUES
 (N'Học tập', N'Bài tập, ôn thi, đồ án'),
 (N'Công việc', N'Việc làm thêm, dự án'),
 (N'Cá nhân', N'Sức khỏe, mua sắm, gia đình');
-- 25 công việc mẫu cho member để thử phân trang
DECLARE @i INT = 1;
WHILE @i <= 25
BEGIN
  INSERT INTO Tasks(UserId, CategoryId, Title, Description, DueDate, Priority)
  VALUES (2, ((@i - 1) % 3) + 1, CONCAT(N'Công việc mẫu ', @i), N'Mô tả công việc mẫu',
          DATEADD(DAY, @i, SYSUTCDATETIME()), ((@i - 1) % 3) + 1);
  SET @i += 1;
END
GO
