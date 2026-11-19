using Microsoft.EntityFrameworkCore;
using TaskReminder.Api.Data.Entities;

namespace TaskReminder.Api.Data;

/// <summary>
/// Chạy khi API khởi động: bảo đảm có 2 role và 2 tài khoản mẫu
/// (admin@nhacviec.local / Admin@123, member@nhacviec.local / Member@123).
/// Script db/02_seed.sql đã có sẵn hash BCrypt; seeder này để phòng trường hợp chưa chạy seed
/// hoặc hash trong DB vẫn là chuỗi giả "REPLACE_WITH_BCRYPT".
/// </summary>
public static class DbSeeder
{
    public static async Task SeedAsync(AppDbContext db)
    {
        foreach (var name in new[] { Role.Admin, Role.Member })
        {
            if (!await db.Roles.AnyAsync(r => r.Name == name))
                db.Roles.Add(new Role { Name = name });
        }
        await db.SaveChangesAsync();

        var adminRoleId = await db.Roles.Where(r => r.Name == Role.Admin).Select(r => r.Id).FirstAsync();
        var memberRoleId = await db.Roles.Where(r => r.Name == Role.Member).Select(r => r.Id).FirstAsync();

        await EnsureUserAsync(db, "admin@nhacviec.local", "Admin@123", "Quản trị viên", adminRoleId);
        await EnsureUserAsync(db, "member@nhacviec.local", "Member@123", "Người dùng mẫu", memberRoleId);
        await db.SaveChangesAsync();
    }

    private static async Task EnsureUserAsync(AppDbContext db, string email, string password, string fullName, int roleId)
    {
        var user = await db.Users.FirstOrDefaultAsync(u => u.Email == email);
        if (user == null)
        {
            db.Users.Add(new User
            {
                Email = email,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(password),
                FullName = fullName,
                RoleId = roleId,
                EmailConfirmed = true
            });
        }
        else if (user.PasswordHash == null || !user.PasswordHash.StartsWith("$2"))
        {
            // Hash không phải BCrypt (ví dụ "REPLACE_WITH_BCRYPT") → băm lại mật khẩu mẫu
            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(password);
        }
    }
}
