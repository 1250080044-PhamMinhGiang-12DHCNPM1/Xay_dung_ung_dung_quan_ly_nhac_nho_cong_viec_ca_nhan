using System.Security.Claims;
using System.Text;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.JsonWebTokens;
using Microsoft.IdentityModel.Tokens;
using TaskReminder.Api.Common;
using TaskReminder.Api.Data;
using TaskReminder.Api.Data.Entities;
using TaskReminder.Api.DTOs;

namespace TaskReminder.Api.Services;

/// <summary>
/// Nghiệp vụ xác thực: đăng ký, đăng nhập, đổi mật khẩu, lấy thông tin người dùng, tạo JWT.
/// (OTP email do An bổ sung ở task 04; đăng nhập Google ở task 05 dùng lại CreateLoginResponse.)
/// </summary>
public class AuthService
{
    private readonly AppDbContext _db;
    private readonly IConfiguration _config;

    public AuthService(AppDbContext db, IConfiguration config)
    {
        _db = db;
        _config = config;
    }

    /// <summary>Cờ tạm: false thì cho đăng nhập dù chưa xác thực email (khi OTP chưa làm xong).</summary>
    private bool RequireEmailConfirmation => _config.GetValue<bool>("Auth:RequireEmailConfirmation");

    public static string NormalizeEmail(string email) => email.Trim().ToLowerInvariant();

    public async Task<UserDto> RegisterAsync(RegisterRequest req)
    {
        var email = NormalizeEmail(req.Email);
        if (await _db.Users.AnyAsync(u => u.Email == email))
            throw new AppException(StatusCodes.Status409Conflict, "Email đã được sử dụng");

        var memberRole = await _db.Roles.FirstAsync(r => r.Name == Role.Member);
        var user = new User
        {
            Email = email,
            // BCrypt tự sinh salt ngẫu nhiên và gắn salt vào chuỗi hash ($2a$11$<salt><hash>).
            // Không giải ngược được: chỉ có thể băm lại mật khẩu nhập vào rồi so sánh.
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(req.Password),
            FullName = req.FullName.Trim(),
            RoleId = memberRole.Id,
            EmailConfirmed = false,
            Role = memberRole
        };
        _db.Users.Add(user);
        await _db.SaveChangesAsync();

        // TODO(An - task 04): sinh OTP mục đích VerifyEmail và gửi email xác thực tại đây.

        return ToDto(user);
    }

    public async Task<LoginResponse> LoginAsync(LoginRequest req)
    {
        var email = NormalizeEmail(req.Email);
        var user = await _db.Users.Include(u => u.Role).FirstOrDefaultAsync(u => u.Email == email);

        // Không nói rõ sai email hay sai mật khẩu, tránh lộ email nào đã đăng ký
        if (user == null || !VerifyPassword(req.Password, user.PasswordHash))
            throw new AppException(StatusCodes.Status401Unauthorized, "Email hoặc mật khẩu không đúng");

        if (user.IsLocked)
            throw new AppException(StatusCodes.Status403Forbidden, "Tài khoản đã bị khóa");
        if (RequireEmailConfirmation && !user.EmailConfirmed)
            throw new AppException(StatusCodes.Status403Forbidden, "Tài khoản chưa xác thực email");

        return CreateLoginResponse(user);
    }

    public async Task<UserDto> GetMeAsync(int userId)
    {
        var user = await _db.Users.Include(u => u.Role).FirstOrDefaultAsync(u => u.Id == userId)
            ?? throw new AppException(StatusCodes.Status404NotFound, "Không tìm thấy người dùng");
        return ToDto(user);
    }

    public async Task ChangePasswordAsync(int userId, ChangePasswordRequest req)
    {
        var user = await _db.Users.FindAsync(userId)
            ?? throw new AppException(StatusCodes.Status404NotFound, "Không tìm thấy người dùng");

        if (user.PasswordHash == null)
            throw new AppException(StatusCodes.Status400BadRequest, "Tài khoản đăng nhập bằng Google chưa có mật khẩu");

        // Kiểm tra mật khẩu cũ: BCrypt lấy salt trong hash đang lưu, băm mật khẩu cũ người dùng nhập rồi so sánh
        if (!VerifyPassword(req.OldPassword, user.PasswordHash))
            throw new AppException(StatusCodes.Status400BadRequest, "Mật khẩu cũ không đúng");
        if (req.OldPassword == req.NewPassword)
            throw new AppException(StatusCodes.Status400BadRequest, "Mật khẩu mới phải khác mật khẩu cũ");

        user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(req.NewPassword);
        await _db.SaveChangesAsync();
    }

    /// <summary>
    /// Tạo JWT + thông tin người dùng. user phải được Include(Role).
    /// JWT = header.payload.signature (base64url), ký bằng HMAC-SHA256 với Jwt:Key bí mật.
    /// Payload chứa: sub (Id), email, name, role, exp (hết hạn).
    /// Ai sửa payload (vd đổi role thành Admin) thì chữ ký không khớp → API từ chối (401).
    /// </summary>
    public LoginResponse CreateLoginResponse(User user)
    {
        var roleName = user.Role?.Name ?? throw new InvalidOperationException("User chưa Include(Role)");
        var expiresAt = DateTime.UtcNow.AddMinutes(_config.GetValue("Jwt:ExpiresMinutes", 1440));
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]!));

        var descriptor = new SecurityTokenDescriptor
        {
            Issuer = _config["Jwt:Issuer"],
            Audience = _config["Jwt:Audience"],
            Expires = expiresAt,
            SigningCredentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256),
            Subject = new ClaimsIdentity(new[]
            {
                new Claim("sub", user.Id.ToString()),
                new Claim("email", user.Email),
                new Claim("name", user.FullName),
                new Claim("role", roleName)
            })
        };

        return new LoginResponse
        {
            Token = new JsonWebTokenHandler().CreateToken(descriptor),
            ExpiresAt = expiresAt,
            User = ToDto(user)
        };
    }

    private static bool VerifyPassword(string password, string? hash)
    {
        if (string.IsNullOrEmpty(hash)) return false; // tài khoản chỉ đăng nhập Google
        try
        {
            return BCrypt.Net.BCrypt.Verify(password, hash);
        }
        catch (BCrypt.Net.SaltParseException)
        {
            return false; // hash trong DB không đúng định dạng BCrypt
        }
    }

    public static UserDto ToDto(User u) => new()
    {
        Id = u.Id,
        Email = u.Email,
        FullName = u.FullName,
        Role = u.Role?.Name ?? "",
        AvatarUrl = u.AvatarUrl
    };
}
