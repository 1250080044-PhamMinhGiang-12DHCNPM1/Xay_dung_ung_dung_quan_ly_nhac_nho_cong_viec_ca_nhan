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
        var user = await _auth.RegisterAsync(req);
        return StatusCode(StatusCodes.Status201Created, ApiResponse<UserDto>.Ok(user, "Đăng ký thành công"));
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
}
