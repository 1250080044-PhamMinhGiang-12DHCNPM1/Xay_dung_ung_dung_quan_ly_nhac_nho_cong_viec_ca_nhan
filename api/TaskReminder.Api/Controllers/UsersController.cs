using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TaskReminder.Api.Common;
using TaskReminder.Api.DTOs;
using TaskReminder.Api.Services;

namespace TaskReminder.Api.Controllers;

/// <summary>
/// Quản lý member - CHỈ Admin. Phân quyền thật nằm ở đây:
/// token của Member gọi vào sẽ bị trả 403 dù app có ẩn menu hay không.
/// </summary>
[ApiController]
[Route("api/users")]
[Authorize(Roles = "Admin")]
public class UsersController : ControllerBase
{
    private readonly UserService _users;

    public UsersController(UserService users)
    {
        _users = users;
    }

    /// <summary>GET /api/users?keyword&amp;page&amp;pageSize</summary>
    [HttpGet]
    public async Task<ActionResult<ApiResponse<PagedResult<UserListItemDto>>>> GetUsers(
        [FromQuery] string? keyword, [FromQuery] int? page, [FromQuery] int? pageSize)
    {
        var result = await _users.GetUsersAsync(keyword, page, pageSize);
        return Ok(ApiResponse<PagedResult<UserListItemDto>>.Ok(result));
    }

    /// <summary>PUT /api/users/{id}/role  body: {role: "Admin"|"Member"}</summary>
    [HttpPut("{id:int}/role")]
    public async Task<ActionResult<ApiResponse<object>>> UpdateRole(int id, UpdateRoleRequest req)
    {
        await _users.UpdateRoleAsync(User.GetUserId(), id, req.Role);
        return Ok(ApiResponse.Ok("Đã cập nhật role"));
    }

    /// <summary>PUT /api/users/{id}/lock  body: {isLocked: bool}</summary>
    [HttpPut("{id:int}/lock")]
    public async Task<ActionResult<ApiResponse<object>>> UpdateLock(int id, UpdateLockRequest req)
    {
        var isLocked = req.IsLocked!.Value;
        await _users.UpdateLockAsync(User.GetUserId(), id, isLocked);
        return Ok(ApiResponse.Ok(isLocked ? "Đã khóa tài khoản" : "Đã mở khóa tài khoản"));
    }
}
