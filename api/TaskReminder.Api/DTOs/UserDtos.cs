using System.ComponentModel.DataAnnotations;

namespace TaskReminder.Api.DTOs;

/// <summary>Một dòng trong danh sách member (Admin).</summary>
public class UserListItemDto
{
    public int Id { get; set; }
    public string Email { get; set; } = "";
    public string FullName { get; set; } = "";
    public string Role { get; set; } = "";
    public string? AvatarUrl { get; set; }
    public bool IsLocked { get; set; }
    public bool EmailConfirmed { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class UpdateRoleRequest
{
    [Required(ErrorMessage = "Vui lòng chọn role")]
    [RegularExpression("^(Admin|Member)$", ErrorMessage = "Role chỉ được là Admin hoặc Member")]
    public string Role { get; set; } = "";
}

public class UpdateLockRequest
{
    // bool? + [Required] để bắt buộc client gửi isLocked (bool thường sẽ mặc định false)
    [Required(ErrorMessage = "Thiếu trường isLocked")]
    public bool? IsLocked { get; set; }
}
