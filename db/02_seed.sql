USE TaskReminderDb;
GO
INSERT INTO Roles(Name) VALUES (N'Admin'), (N'Member');
-- Mật khẩu mẫu: Admin@123 và Member@123.
-- PasswordHash phải là chuỗi BCrypt thật. Claude Code: khi làm task 01, sinh hash bằng BCrypt.Net
-- và thay 2 giá trị REPLACE_WITH_BCRYPT bên dưới (hoặc seed bằng code khi API khởi động lần đầu).
INSERT INTO Users(Email, PasswordHash, FullName, RoleId, EmailConfirmed)
VALUES (N'admin@nhacviec.local', N'REPLACE_WITH_BCRYPT', N'Quản trị viên', 1, 1),
       (N'member@nhacviec.local', N'REPLACE_WITH_BCRYPT', N'Người dùng mẫu', 2, 1);
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
