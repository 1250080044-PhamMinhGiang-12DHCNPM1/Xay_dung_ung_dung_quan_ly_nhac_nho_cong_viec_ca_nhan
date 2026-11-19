using System.ComponentModel.DataAnnotations;

namespace TaskReminder.Api.DTOs;

// Validate bằng DataAnnotations: [ApiController] tự kiểm tra trước khi vào action,
// sai thì trả 400 (xem cấu hình InvalidModelStateResponseFactory trong Program.cs).

public class RegisterRequest
{
    [Required(ErrorMessage = "Vui lòng nhập email")]
    [EmailAddress(ErrorMessage = "Email không hợp lệ")]
    [MaxLength(150, ErrorMessage = "Email tối đa 150 ký tự")]
    public string Email { get; set; } = "";

    [Required(ErrorMessage = "Vui lòng nhập mật khẩu")]
    [MinLength(6, ErrorMessage = "Mật khẩu tối thiểu 6 ký tự")]
    [MaxLength(100, ErrorMessage = "Mật khẩu tối đa 100 ký tự")]
    public string Password { get; set; } = "";

    [Required(ErrorMessage = "Vui lòng nhập họ tên")]
    [MaxLength(100, ErrorMessage = "Họ tên tối đa 100 ký tự")]
    public string FullName { get; set; } = "";
}

public class LoginRequest
{
    [Required(ErrorMessage = "Vui lòng nhập email")]
    [EmailAddress(ErrorMessage = "Email không hợp lệ")]
    public string Email { get; set; } = "";

    [Required(ErrorMessage = "Vui lòng nhập mật khẩu")]
    public string Password { get; set; } = "";
}

public class ChangePasswordRequest
{
    [Required(ErrorMessage = "Vui lòng nhập mật khẩu cũ")]
    public string OldPassword { get; set; } = "";

    [Required(ErrorMessage = "Vui lòng nhập mật khẩu mới")]
    [MinLength(6, ErrorMessage = "Mật khẩu mới tối thiểu 6 ký tự")]
    [MaxLength(100, ErrorMessage = "Mật khẩu mới tối đa 100 ký tự")]
    public string NewPassword { get; set; } = "";
}

/// <summary>Thông tin người dùng trả về cho app: {id, email, fullName, role, avatarUrl}.</summary>
public class UserDto
{
    public int Id { get; set; }
    public string Email { get; set; } = "";
    public string FullName { get; set; } = "";
    public string Role { get; set; } = "";
    public string? AvatarUrl { get; set; }
}

/// <summary>Kết quả đăng nhập: {token, expiresAt, user}.</summary>
public class LoginResponse
{
    public string Token { get; set; } = "";
    public DateTime ExpiresAt { get; set; }
    public UserDto User { get; set; } = new();
}

// ---------------- OTP email (task 04 - An) ----------------

public class VerifyEmailRequest
{
    [Required(ErrorMessage = "Vui lòng nhập email")]
    [EmailAddress(ErrorMessage = "Email không hợp lệ")]
    public string Email { get; set; } = "";

    [Required(ErrorMessage = "Vui lòng nhập mã OTP")]
    [RegularExpression(@"^\d{6}$", ErrorMessage = "Mã OTP gồm 6 chữ số")]
    public string Code { get; set; } = "";
}

public class ResendOtpRequest
{
    [Required(ErrorMessage = "Vui lòng nhập email")]
    [EmailAddress(ErrorMessage = "Email không hợp lệ")]
    public string Email { get; set; } = "";

    [Required(ErrorMessage = "Thiếu mục đích gửi mã")]
    [RegularExpression("^(VerifyEmail|ResetPassword)$", ErrorMessage = "Mục đích chỉ được là VerifyEmail hoặc ResetPassword")]
    public string Purpose { get; set; } = "";
}

public class ForgotPasswordRequest
{
    [Required(ErrorMessage = "Vui lòng nhập email")]
    [EmailAddress(ErrorMessage = "Email không hợp lệ")]
    public string Email { get; set; } = "";
}

public class ResetPasswordRequest
{
    [Required(ErrorMessage = "Vui lòng nhập email")]
    [EmailAddress(ErrorMessage = "Email không hợp lệ")]
    public string Email { get; set; } = "";

    [Required(ErrorMessage = "Vui lòng nhập mã OTP")]
    [RegularExpression(@"^\d{6}$", ErrorMessage = "Mã OTP gồm 6 chữ số")]
    public string Code { get; set; } = "";

    [Required(ErrorMessage = "Vui lòng nhập mật khẩu mới")]
    [MinLength(6, ErrorMessage = "Mật khẩu mới tối thiểu 6 ký tự")]
    [MaxLength(100, ErrorMessage = "Mật khẩu mới tối đa 100 ký tự")]
    public string NewPassword { get; set; } = "";
}
