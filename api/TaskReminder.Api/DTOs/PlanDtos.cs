using System.ComponentModel.DataAnnotations;

namespace TaskReminder.Api.DTOs;

/// <summary>Body của POST /api/plans: {planDate, note, items:[{taskId, minutes}]}.</summary>
public class CreatePlanRequest
{
    [Required(ErrorMessage = "Vui lòng chọn ngày kế hoạch")]
    public DateOnly? PlanDate { get; set; }

    [MaxLength(500, ErrorMessage = "Ghi chú tối đa 500 ký tự")]
    public string? Note { get; set; }

    [Required(ErrorMessage = "Kế hoạch phải có ít nhất 1 công việc")]
    [MinLength(1, ErrorMessage = "Kế hoạch phải có ít nhất 1 công việc")]
    public List<CreatePlanItemRequest> Items { get; set; } = new();
}

public class CreatePlanItemRequest
{
    [Required(ErrorMessage = "Thiếu taskId")]
    public int? TaskId { get; set; }

    /// <summary>Thời lượng dự kiến (phút) - tương đương "số lượng" trong giỏ hàng.</summary>
    [Range(1, 1440, ErrorMessage = "Số phút phải từ 1 đến 1440")]
    public int Minutes { get; set; }
}

/// <summary>Một kế hoạch trong lịch sử (GET /api/plans).</summary>
public class PlanSummaryDto
{
    public int Id { get; set; }
    public DateOnly PlanDate { get; set; }
    public string Status { get; set; } = "";
    public int TotalMinutes { get; set; }
    public string? Note { get; set; }
    public int ItemCount { get; set; }
    public DateTime CreatedAt { get; set; }
}

/// <summary>Chi tiết kế hoạch kèm danh sách công việc (GET /api/plans/{id}, kết quả POST).</summary>
public class PlanDetailDto : PlanSummaryDto
{
    public List<PlanItemDto> Items { get; set; } = new();
}

public class PlanItemDto
{
    public int Id { get; set; }
    public int TaskId { get; set; }
    public string Title { get; set; } = "";
    public string CategoryName { get; set; } = "";
    public string? ImageUrl { get; set; }
    public string TaskStatus { get; set; } = "";
    public int Minutes { get; set; }
}
