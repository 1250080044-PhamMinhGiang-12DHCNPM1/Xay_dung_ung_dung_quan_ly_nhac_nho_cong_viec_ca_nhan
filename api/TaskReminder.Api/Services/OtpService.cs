using System.Security.Cryptography;
using Microsoft.EntityFrameworkCore;
using TaskReminder.Api.Common;
using TaskReminder.Api.Data;
using TaskReminder.Api.Data.Entities;

namespace TaskReminder.Api.Services;

/// <summary>
/// Sinh, gửi và kiểm tra mã OTP qua email (bảng EmailOtps) - task 04 - An.
/// Quy tắc (docs/API.md): 6 chữ số, sinh bằng RandomNumberGenerator, lưu BẢN BĂM,
/// hết hạn 5 phút, dùng 1 lần, sai quá 5 lần thì hủy, gửi lại cách nhau tối thiểu 60 giây.
/// </summary>
public class OtpService
{
    public const int ExpireMinutes = 5;
    public const int MaxAttempts = 5;
    public const int ResendSeconds = 60;

    private readonly AppDbContext _db;
    private readonly EmailService _email;

    public OtpService(AppDbContext db, EmailService email)
    {
        _db = db;
        _email = email;
    }

    /// <summary>
    /// Tạo mã OTP mới cho user + mục đích (VerifyEmail | ResetPassword) và gửi email.
    /// Chưa đủ 60 giây kể từ mã trước → ném lỗi 400 (chống spam gửi mail).
    /// </summary>
    public async Task CreateAndSendAsync(User user, string purpose)
    {
        // Kiểm tra thời gian gửi lại: lấy mã gần nhất cùng mục đích
        var lastCreatedAt = await _db.EmailOtps
            .Where(o => o.UserId == user.Id && o.Purpose == purpose)
            .OrderByDescending(o => o.CreatedAt)
            .Select(o => (DateTime?)o.CreatedAt)
            .FirstOrDefaultAsync();
        if (lastCreatedAt.HasValue)
        {
            var waited = (DateTime.UtcNow - lastCreatedAt.Value).TotalSeconds;
            if (waited < ResendSeconds)
                throw new AppException(StatusCodes.Status400BadRequest,
                    $"Vui lòng đợi {Math.Ceiling(ResendSeconds - waited)} giây trước khi gửi lại mã");
        }

        // Mã mới thay thế mã cũ: xóa các mã chưa dùng cùng mục đích
        var oldOtps = await _db.EmailOtps
            .Where(o => o.UserId == user.Id && o.Purpose == purpose && o.UsedAt == null)
            .ToListAsync();
        _db.EmailOtps.RemoveRange(oldOtps);

        // Sinh 6 chữ số bằng RandomNumberGenerator (ngẫu nhiên an toàn cho mật mã, không đoán trước được
        // như Random thường). GetInt32(0, 1_000_000) cho 0..999999, "D6" thêm số 0 ở đầu: 42 → "000042".
        var code = RandomNumberGenerator.GetInt32(0, 1_000_000).ToString("D6");

        _db.EmailOtps.Add(new EmailOtp
        {
            UserId = user.Id,
            // Chỉ lưu BẢN BĂM (BCrypt) - người đọc được CSDL cũng không biết mã thật
            CodeHash = BCrypt.Net.BCrypt.HashPassword(code),
            Purpose = purpose,
            ExpiresAt = DateTime.UtcNow.AddMinutes(ExpireMinutes),
            Attempts = 0
        });
        await _db.SaveChangesAsync();

        await _email.SendOtpAsync(user.Email, user.FullName, code, purpose, ExpireMinutes);
    }

    /// <summary>
    /// Kiểm tra mã OTP người dùng nhập. Đúng → đánh dấu đã dùng (UsedAt) và trả về user.
    /// Sai → tăng Attempts; sai tới lần thứ 5 thì hủy mã. Ném AppException(400) khi không hợp lệ.
    /// </summary>
    public async Task<User> VerifyAsync(string email, string purpose, string code)
    {
        const string invalidMessage = "Mã OTP không đúng hoặc đã hết hạn";

        var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == email)
            ?? throw new AppException(StatusCodes.Status400BadRequest, invalidMessage);

        // Chỉ xét mã mới nhất còn hiệu lực (chưa dùng / chưa bị hủy)
        var otp = await _db.EmailOtps
            .Where(o => o.UserId == user.Id && o.Purpose == purpose && o.UsedAt == null)
            .OrderByDescending(o => o.CreatedAt)
            .FirstOrDefaultAsync();

        if (otp == null || otp.ExpiresAt < DateTime.UtcNow)
            throw new AppException(StatusCodes.Status400BadRequest, invalidMessage);

        // So sánh: băm mã người dùng nhập rồi đối chiếu với CodeHash (giống kiểm tra mật khẩu)
        if (!BCrypt.Net.BCrypt.Verify(code, otp.CodeHash))
        {
            otp.Attempts++;
            if (otp.Attempts >= MaxAttempts)
            {
                otp.UsedAt = DateTime.UtcNow; // hủy mã: không dùng được nữa
                await _db.SaveChangesAsync();
                throw new AppException(StatusCodes.Status400BadRequest,
                    $"Nhập sai quá {MaxAttempts} lần, mã OTP đã bị hủy. Vui lòng gửi lại mã mới");
            }
            await _db.SaveChangesAsync();
            throw new AppException(StatusCodes.Status400BadRequest,
                $"Mã OTP không đúng (còn {MaxAttempts - otp.Attempts} lần thử)");
        }

        otp.UsedAt = DateTime.UtcNow; // dùng 1 lần
        await _db.SaveChangesAsync();
        return user;
    }
}
