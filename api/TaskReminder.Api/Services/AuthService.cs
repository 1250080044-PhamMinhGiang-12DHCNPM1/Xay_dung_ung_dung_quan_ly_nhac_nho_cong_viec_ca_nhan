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
    private readonly OtpService _otp;
    private readonly ILogger<AuthService> _logger;

    public AuthService(AppDbContext db, IConfiguration config, OtpService otp, ILogger<AuthService> logger)
    {
        _db = db;
        _config = config;
        _otp = otp;
        _logger = logger;
    }

    /// <summary>Cờ tạm: false thì cho đăng nhập dù chưa xác thực email (khi OTP chưa làm xong).</summary>
    private bool RequireEmailConfirmation => _config.GetValue<bool>("Auth:RequireEmailConfirmation");

    public static string NormalizeEmail(string email) => email.Trim().ToLowerInvariant();

    /// <summary>Đăng ký Member; trả về user và cờ đã gửi được email OTP xác thực hay chưa.</summary>
    public async Task<(UserDto User, bool OtpSent)> RegisterAsync(RegisterRequest req)
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

        // Gửi OTP xác thực email (task 04). Gửi mail lỗi thì vẫn giữ tài khoản đã tạo,
        // người dùng bấm "Gửi lại mã" (resend-otp) sau.
        var otpSent = true;
        try
        {
            await _otp.CreateAndSendAsync(user, EmailOtp.PurposeVerifyEmail);
        }
        catch (Exception ex)
        {
            otpSent = false;
            _logger.LogError(ex, "Không gửi được OTP xác thực cho {Email}", user.Email);
        }

        return (ToDto(user), otpSent);
    }

    // ---------------- OTP email (task 04 - An) ----------------

    /// <summary>POST /api/auth/verify-email: mã đúng → EmailConfirmed = true.</summary>
    public async Task VerifyEmailAsync(VerifyEmailRequest req)
    {
        var user = await _otp.VerifyAsync(NormalizeEmail(req.Email), EmailOtp.PurposeVerifyEmail, req.Code);
        user.EmailConfirmed = true;
        await _db.SaveChangesAsync();
    }

    /// <summary>
    /// POST /api/auth/resend-otp: gửi lại mã (cách mã trước tối thiểu 60 giây).
    /// Email không tồn tại thì không gửi nhưng vẫn trả thành công (không lộ email nào đã đăng ký).
    /// </summary>
    public async Task ResendOtpAsync(ResendOtpRequest req)
    {
        var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == NormalizeEmail(req.Email));
        if (user == null) return;
        if (req.Purpose == EmailOtp.PurposeVerifyEmail && user.EmailConfirmed)
            throw new AppException(StatusCodes.Status400BadRequest, "Email đã được xác thực, bạn có thể đăng nhập");

        await _otp.CreateAndSendAsync(user, req.Purpose);
    }

    /// <summary>
    /// POST /api/auth/forgot-password: LUÔN trả thành công, kể cả email không tồn tại hoặc đang chờ 60 giây,
    /// để kẻ xấu không dò được email nào đã đăng ký.
    /// </summary>
    public async Task ForgotPasswordAsync(ForgotPasswordRequest req)
    {
        var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == NormalizeEmail(req.Email));
        if (user == null) return;
        try
        {
            await _otp.CreateAndSendAsync(user, EmailOtp.PurposeResetPassword);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Không gửi được OTP đặt lại mật khẩu cho {Email}", user.Email);
        }
    }

    /// <summary>POST /api/auth/reset-password: mã đúng → băm và lưu mật khẩu mới.</summary>
    public async Task ResetPasswordAsync(ResetPasswordRequest req)
    {
        var user = await _otp.VerifyAsync(NormalizeEmail(req.Email), EmailOtp.PurposeResetPassword, req.Code);
        user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(req.NewPassword);
        user.EmailConfirmed = true; // nhận được mã qua email nghĩa là đã chứng minh sở hữu email
        await _db.SaveChangesAsync();
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
