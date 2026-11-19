using Microsoft.EntityFrameworkCore;
using TaskReminder.Api.Common;
using TaskReminder.Api.Data;
using TaskReminder.Api.Data.Entities;
using TaskReminder.Api.DTOs;

namespace TaskReminder.Api.Services;

/// <summary>Admin quản lý member: danh sách/tìm kiếm có phân trang, đổi role, khóa/mở khóa.</summary>
public class UserService
{
    private readonly AppDbContext _db;

    public UserService(AppDbContext db)
    {
        _db = db;
    }

    public Task<PagedResult<UserListItemDto>> GetUsersAsync(string? keyword, int? page, int? pageSize)
    {
        var query = _db.Users.AsNoTracking().AsQueryable();

        // Tìm theo email hoặc họ tên (SQL: LIKE N'%keyword%')
        if (!string.IsNullOrWhiteSpace(keyword))
        {
            var kw = keyword.Trim();
            query = query.Where(u => u.Email.Contains(kw) || u.FullName.Contains(kw));
        }

        return query
            .OrderBy(u => u.Id)
            .Select(u => new UserListItemDto
            {
                Id = u.Id,
                Email = u.Email,
                FullName = u.FullName,
                Role = u.Role!.Name,
                AvatarUrl = u.AvatarUrl,
                IsLocked = u.IsLocked,
                EmailConfirmed = u.EmailConfirmed,
                CreatedAt = u.CreatedAt
            })
            .ToPagedResultAsync(page, pageSize);
    }

    public async Task UpdateRoleAsync(int currentUserId, int userId, string roleName)
    {
        // Không cho Admin tự hạ quyền mình, tránh trường hợp hệ thống không còn Admin nào
        if (userId == currentUserId && roleName != Role.Admin)
            throw new AppException(StatusCodes.Status400BadRequest, "Không thể tự hạ quyền của chính mình");

        var user = await _db.Users.FindAsync(userId)
            ?? throw new AppException(StatusCodes.Status404NotFound, "Không tìm thấy người dùng");
        var role = await _db.Roles.FirstOrDefaultAsync(r => r.Name == roleName)
            ?? throw new AppException(StatusCodes.Status400BadRequest, "Role không hợp lệ");

        user.RoleId = role.Id;
        await _db.SaveChangesAsync();
    }

    public async Task UpdateLockAsync(int currentUserId, int userId, bool isLocked)
    {
        if (userId == currentUserId && isLocked)
            throw new AppException(StatusCodes.Status400BadRequest, "Không thể tự khóa tài khoản của chính mình");

        var user = await _db.Users.FindAsync(userId)
            ?? throw new AppException(StatusCodes.Status404NotFound, "Không tìm thấy người dùng");

        user.IsLocked = isLocked;
        await _db.SaveChangesAsync();
    }
}
