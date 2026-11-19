namespace TaskReminder.Api.Data.Entities;

/// <summary>
/// Bảng Plans - kế hoạch đã chốt (tương đương "đơn hàng"). Task 04 (An) và 03 (Hiếu).
/// Status: Confirmed → InProgress → Completed; Confirmed/InProgress → Cancelled.
/// </summary>
public class Plan
{
    public const string StatusConfirmed = "Confirmed";
    public const string StatusInProgress = "InProgress";
    public const string StatusCompleted = "Completed";
    public const string StatusCancelled = "Cancelled";

    public int Id { get; set; }
    public int UserId { get; set; }
    /// <summary>Cột DATE (chỉ ngày, không giờ).</summary>
    public DateOnly PlanDate { get; set; }
    public string Status { get; set; } = StatusConfirmed;
    public int TotalMinutes { get; set; }
    public string? Note { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public User? User { get; set; }
    public List<PlanItem> Items { get; set; } = new();
}
