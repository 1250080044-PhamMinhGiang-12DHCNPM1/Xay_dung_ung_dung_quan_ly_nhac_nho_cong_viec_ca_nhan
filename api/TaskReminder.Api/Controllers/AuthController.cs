using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TaskReminder.Api.Common;
using TaskReminder.Api.DTOs;
using TaskReminder.Api.Services;

namespace TaskReminder.Api.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly AuthService _auth;

    public AuthController(AuthService auth)
    {
        _auth = auth;
    }

    /// <summary>POST /api/auth/register - tạo tài khoản Member.</summary>
    [HttpPost("register")]
    public async Task<ActionResult<ApiResponse<UserDto>>> Register(RegisterRequest req)
    {
        var (user, otpSent) = await _auth.RegisterAsync(req);
        var message = otpSent
            ? "Đăng ký thành công. Mã OTP xác thực đã được gửi tới email của bạn"
            : "Đăng ký thành công nhưng chưa gửi được email. Vui lòng bấm \"Gửi lại mã\"";
        return StatusCode(StatusCodes.Status201Created, ApiResponse<UserDto>.Ok(user, message));
    }

    /// <summary>POST /api/auth/login - trả JWT.</summary>
    [HttpPost("login")]
    public async Task<ActionResult<ApiResponse<LoginResponse>>> Login(LoginRequest req)
    {
        var result = await _auth.LoginAsync(req);
        return Ok(ApiResponse<LoginResponse>.Ok(result, "Đăng nhập thành công"));
    }

    /// <summary>GET /api/auth/me - thông tin người dùng đang đăng nhập.</summary>
    [Authorize]
    [HttpGet("me")]
    public async Task<ActionResult<ApiResponse<UserDto>>> Me()
    {
        var user = await _auth.GetMeAsync(User.GetUserId());
        return Ok(ApiResponse<UserDto>.Ok(user));
    }

    /// <summary>POST /api/auth/change-password - đổi mật khẩu, phải đúng mật khẩu cũ.</summary>
    [Authorize]
    [HttpPost("change-password")]
    public async Task<ActionResult<ApiResponse<object>>> ChangePassword(ChangePasswordRequest req)
    {
        await _auth.ChangePasswordAsync(User.GetUserId(), req);
        return Ok(ApiResponse.Ok("Đổi mật khẩu thành công"));
    }

    // ---------------- OTP email (task 04 - An) ----------------

    /// <summary>POST /api/auth/verify-email  body: {email, code}</summary>
    [HttpPost("verify-email")]
    public async Task<ActionResult<ApiResponse<object>>> VerifyEmail(VerifyEmailRequest req)
    {
        await _auth.VerifyEmailAsync(req);
        return Ok(ApiResponse.Ok("Xác thực email thành công, bạn có thể đăng nhập"));
    }

    /// <summary>POST /api/auth/resend-otp  body: {email, purpose: "VerifyEmail"|"ResetPassword"}</summary>
    [HttpPost("resend-otp")]
    public async Task<ActionResult<ApiResponse<object>>> ResendOtp(ResendOtpRequest req)
    {
        await _auth.ResendOtpAsync(req);
        return Ok(ApiResponse.Ok("Nếu email hợp lệ, mã OTP mới đã được gửi"));
    }

    /// <summary>POST /api/auth/forgot-password  body: {email} - luôn trả success</summary>
    [HttpPost("forgot-password")]
    public async Task<ActionResult<ApiResponse<object>>> ForgotPassword(ForgotPasswordRequest req)
    {
        await _auth.ForgotPasswordAsync(req);
        return Ok(ApiResponse.Ok("Nếu email đã đăng ký, mã OTP đặt lại mật khẩu đã được gửi"));
    }

    /// <summary>POST /api/auth/reset-password  body: {email, code, newPassword}</summary>
    [HttpPost("reset-password")]
    public async Task<ActionResult<ApiResponse<object>>> ResetPassword(ResetPasswordRequest req)
    {
        await _auth.ResetPasswordAsync(req);
        return Ok(ApiResponse.Ok("Đặt lại mật khẩu thành công, hãy đăng nhập bằng mật khẩu mới"));
    }
}
