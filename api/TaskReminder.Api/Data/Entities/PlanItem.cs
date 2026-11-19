namespace TaskReminder.Api.Data.Entities;

/// <summary>Bảng PlanItems - công việc trong kế hoạch, Minutes tương đương "số lượng".</summary>
public class PlanItem
{
    public int Id { get; set; }
    public int PlanId { get; set; }
    public int TaskId { get; set; }
    public int Minutes { get; set; }

    public Plan? Plan { get; set; }
    public TaskItem? Task { get; set; }
}
