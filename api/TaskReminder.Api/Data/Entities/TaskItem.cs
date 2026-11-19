namespace TaskReminder.Api.Data.Entities;

/// <summary>
/// Bảng Tasks - công việc (task 03 - Hiếu).
/// Đặt tên class là TaskItem để không trùng với System.Threading.Tasks.Task.
/// </summary>
public class TaskItem
{
    public const string StatusTodo = "Todo";
    public const string StatusDoing = "Doing";
    public const string StatusDone = "Done";

    public int Id { get; set; }
    public int UserId { get; set; }
    public int CategoryId { get; set; }
    public string Title { get; set; } = "";
    public string? Description { get; set; }
    public DateTime? DueDate { get; set; }
    /// <summary>1 thấp, 2 vừa, 3 cao (TINYINT).</summary>
    public byte Priority { get; set; } = 2;
    public string Status { get; set; } = StatusTodo;
    public string? ImageUrl { get; set; }
    public DateTime? ReminderAt { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }

    public User? User { get; set; }
    public Category? Category { get; set; }
    public List<PlanItem> PlanItems { get; set; } = new();
}
