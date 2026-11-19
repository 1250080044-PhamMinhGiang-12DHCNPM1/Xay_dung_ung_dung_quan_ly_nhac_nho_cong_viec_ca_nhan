using System.Net;
using System.Net.Mail;

namespace TaskReminder.Api.Services;

/// <summary>
/// Gửi email qua SMTP Gmail (task 04 - An).
/// Cấu hình trong appsettings.Development.json (đã gitignore, KHÔNG commit):
///   "Smtp": { "Host": "smtp.gmail.com", "Port": 587, "User": "...@gmail.com", "AppPassword": "...", "FromName": "Nhắc việc" }
/// AppPassword là "Mật khẩu ứng dụng" 16 ký tự tạo trong Google Account (cần bật xác minh 2 bước),
/// không phải mật khẩu Gmail.
/// </summary>
public class EmailService
{
    private readonly IConfiguration _config;
    private readonly IWebHostEnvironment _env;
    private readonly ILogger<EmailService> _logger;

    public EmailService(IConfiguration config, IWebHostEnvironment env, ILogger<EmailService> logger)
    {
        _config = config;
        _env = env;
        _logger = logger;
    }

    public async Task SendAsync(string toEmail, string subject, string htmlBody)
    {
        var host = _config["Smtp:Host"];
        var user = _config["Smtp:User"];
        var appPassword = _config["Smtp:AppPassword"];

        if (string.IsNullOrWhiteSpace(appPassword) || string.IsNullOrWhiteSpace(user))
        {
            // Chưa cấu hình SMTP: khi phát triển thì ghi nội dung ra log để vẫn thử được luồng OTP.
            if (_env.IsDevelopment())
            {
                _logger.LogWarning("[EMAIL - chưa cấu hình SMTP, chỉ ghi log] To: {To} | {Subject} | {Body}",
                    toEmail, subject, htmlBody);
                return;
            }
            throw new InvalidOperationException("Chưa cấu hình Smtp:User / Smtp:AppPassword");
        }

        using var message = new MailMessage
        {
            From = new MailAddress(user, _config["Smtp:FromName"] ?? "Nhắc việc"),
            Subject = subject,
            Body = htmlBody,
            IsBodyHtml = true
        };
        message.To.Add(toEmail);

        // Gmail: cổng 587 + STARTTLS (EnableSsl = true), đăng nhập bằng App Password
        using var client = new SmtpClient(host ?? "smtp.gmail.com", _config.GetValue("Smtp:Port", 587))
        {
            EnableSsl = true,
            Credentials = new NetworkCredential(user, appPassword)
        };
        await client.SendMailAsync(message);
    }

    /// <summary>Email chứa mã OTP (HTML đơn giản, tiếng Việt).</summary>
    public Task SendOtpAsync(string toEmail, string fullName, string code, string purpose, int expireMinutes)
    {
        var action = purpose == "ResetPassword" ? "đặt lại mật khẩu" : "xác thực email";
        var subject = purpose == "ResetPassword" ? "Mã đặt lại mật khẩu - Nhắc việc" : "Mã xác thực email - Nhắc việc";
        var body = $"""
            <div style="font-family:Arial,sans-serif;max-width:480px;margin:auto">
              <h2 style="color:#2E7D6B">Nhắc việc</h2>
              <p>Xin chào <b>{WebUtility.HtmlEncode(fullName)}</b>,</p>
              <p>Mã OTP để {action} của bạn là:</p>
              <p style="font-size:32px;font-weight:bold;letter-spacing:8px;color:#2E7D6B">{code}</p>
              <p>Mã có hiệu lực trong <b>{expireMinutes} phút</b> và chỉ dùng được 1 lần.
                 Không chia sẻ mã này cho bất kỳ ai.</p>
              <p style="color:#888;font-size:12px">Nếu bạn không yêu cầu, hãy bỏ qua email này.</p>
            </div>
            """;
        return SendAsync(toEmail, subject, body);
    }
}
