namespace TaskReminder.Api.Data.Entities;

/// <summary>Bảng EmailOtps (task 04 - An). Purpose: VerifyEmail | ResetPassword.</summary>
public class EmailOtp
{
    public const string PurposeVerifyEmail = "VerifyEmail";
    public const string PurposeResetPassword = "ResetPassword";

    public int Id { get; set; }
    public int UserId { get; set; }
    public string CodeHash { get; set; } = "";
    public string Purpose { get; set; } = "";
    public DateTime ExpiresAt { get; set; }
    public DateTime? UsedAt { get; set; }
    public int Attempts { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public User? User { get; set; }
}
