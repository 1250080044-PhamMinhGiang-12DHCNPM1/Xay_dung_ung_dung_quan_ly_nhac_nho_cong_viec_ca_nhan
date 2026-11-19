namespace TaskReminder.Api.Data.Entities;

/// <summary>Bảng Categories - nhóm công việc (task 02 - Bảo).</summary>
public class Category
{
    public int Id { get; set; }
    public string Name { get; set; } = "";
    public string? Description { get; set; }
    public string? ImageUrl { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public List<TaskItem> Tasks { get; set; } = new();
}
