namespace TaskReminder.Api.Data.Entities;

/// <summary>Bảng Users.</summary>
public class User
{
    public int Id { get; set; }
    public string Email { get; set; } = "";
    /// <summary>Chuỗi BCrypt. NULL nếu tài khoản chỉ đăng nhập Google.</summary>
    public string? PasswordHash { get; set; }
    public string FullName { get; set; } = "";
    public string? AvatarUrl { get; set; }
    public int RoleId { get; set; }
    public bool IsLocked { get; set; }
    public bool EmailConfirmed { get; set; }
    public string? GoogleId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Role? Role { get; set; }
}
