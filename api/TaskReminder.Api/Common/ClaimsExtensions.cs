using System.Security.Claims;

namespace TaskReminder.Api.Common;

public static class ClaimsExtensions
{
    /// <summary>
    /// Lấy Id người dùng từ claim "sub" trong JWT.
    /// Các module khác (Task, Plan) dùng hàm này để biết UserId, KHÔNG nhận UserId từ client.
    /// </summary>
    public static int GetUserId(this ClaimsPrincipal user)
    {
        var value = user.FindFirstValue("sub");
        return int.TryParse(value, out var id)
            ? id
            : throw new AppException(StatusCodes.Status401Unauthorized, "Phiên đăng nhập không hợp lệ");
    }
}
