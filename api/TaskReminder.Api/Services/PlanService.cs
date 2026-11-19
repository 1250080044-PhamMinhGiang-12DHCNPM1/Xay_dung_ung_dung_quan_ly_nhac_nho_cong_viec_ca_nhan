using Microsoft.EntityFrameworkCore;
using TaskReminder.Api.Common;
using TaskReminder.Api.Data;
using TaskReminder.Api.Data.Entities;
using TaskReminder.Api.DTOs;

namespace TaskReminder.Api.Services;

/// <summary>
/// Kế hoạch của tôi (task 04 - An): chốt kế hoạch (tương đương "đặt hàng"), lịch sử, chi tiết.
/// Mọi thao tác chỉ trên kế hoạch / công việc của người đang đăng nhập (userId lấy từ JWT).
/// </summary>
public class PlanService
{
    private readonly AppDbContext _db;

    public PlanService(AppDbContext db)
    {
        _db = db;
    }

    /// <summary>
    /// POST /api/plans - chốt kế hoạch từ kế hoạch nháp trên điện thoại.
    /// Dùng TRANSACTION vì phải ghi nhiều bảng (1 dòng Plans + n dòng PlanItems):
    /// hoặc ghi được TẤT CẢ, hoặc không ghi gì (rollback) - không có kế hoạch thiếu công việc.
    /// </summary>
    public async Task<PlanDetailDto> CreateAsync(int userId, CreatePlanRequest req)
    {
        // Gộp các dòng trùng taskId (nếu client gửi trùng) bằng cách cộng số phút
        var items = req.Items
            .GroupBy(i => i.TaskId!.Value)
            .Select(g => new { TaskId = g.Key, Minutes = g.Sum(x => x.Minutes) })
            .ToList();
        var taskIds = items.Select(i => i.TaskId).ToList();

        // Bắt đầu transaction: từ đây đến CommitAsync, các lệnh ghi chưa "chốt" vào CSDL
        await using var transaction = await _db.Database.BeginTransactionAsync();

        // 1) Kiểm tra MỌI taskId đều thuộc người dùng hiện tại.
        //    Đếm số công việc khớp (Id trong danh sách VÀ UserId = userId).
        //    Ít hơn số gửi lên nghĩa là có công việc của người khác hoặc không tồn tại → dừng, không tạo gì.
        var ownedCount = await _db.Tasks.CountAsync(t => taskIds.Contains(t.Id) && t.UserId == userId);
        if (ownedCount != taskIds.Count)
            throw new AppException(StatusCodes.Status400BadRequest,
                "Có công việc không tồn tại hoặc không thuộc về bạn");

        // 2) Tạo Plan. TotalMinutes do server tự tính, không tin số client gửi.
        var plan = new Plan
        {
            UserId = userId,
            PlanDate = req.PlanDate!.Value,
            Status = Plan.StatusConfirmed,
            Note = string.IsNullOrWhiteSpace(req.Note) ? null : req.Note.Trim(),
            TotalMinutes = items.Sum(i => i.Minutes)
        };
        _db.Plans.Add(plan);
        await _db.SaveChangesAsync(); // INSERT Plans → có plan.Id (vẫn nằm trong transaction)

        // 3) Tạo PlanItems trỏ tới plan.Id vừa có
        foreach (var item in items)
            _db.PlanItems.Add(new PlanItem { PlanId = plan.Id, TaskId = item.TaskId, Minutes = item.Minutes });
        await _db.SaveChangesAsync(); // INSERT PlanItems

        // 4) Mọi bước thành công → COMMIT. Nếu có exception ở trên thì không chạy tới đây,
        //    `await using` sẽ hủy transaction → ROLLBACK, dòng Plans ở bước 2 cũng bị hoàn tác.
        await transaction.CommitAsync();

        return await GetDetailAsync(userId, plan.Id);
    }

    /// <summary>GET /api/plans?keyword - kế hoạch của tôi; keyword tìm theo Note hoặc Title công việc.</summary>
    public Task<PagedResult<PlanSummaryDto>> GetMyPlansAsync(int userId, string? keyword, int? page, int? pageSize)
    {
        var query = _db.Plans.AsNoTracking().Where(p => p.UserId == userId);

        if (!string.IsNullOrWhiteSpace(keyword))
        {
            var kw = keyword.Trim();
            query = query.Where(p => (p.Note != null && p.Note.Contains(kw))
                                  || p.Items.Any(i => i.Task!.Title.Contains(kw)));
        }

        return query
            .OrderByDescending(p => p.PlanDate).ThenByDescending(p => p.Id)
            .Select(p => new PlanSummaryDto
            {
                Id = p.Id,
                PlanDate = p.PlanDate,
                Status = p.Status,
                TotalMinutes = p.TotalMinutes,
                Note = p.Note,
                ItemCount = p.Items.Count(),
                CreatedAt = p.CreatedAt
            })
            .ToPagedResultAsync(page, pageSize);
    }

    /// <summary>GET /api/plans/{id} - kế hoạch của người khác trả 404.</summary>
    public async Task<PlanDetailDto> GetDetailAsync(int userId, int id)
    {
        return await _db.Plans.AsNoTracking()
            .Where(p => p.Id == id && p.UserId == userId)
            .Select(p => new PlanDetailDto
            {
                Id = p.Id,
                PlanDate = p.PlanDate,
                Status = p.Status,
                TotalMinutes = p.TotalMinutes,
                Note = p.Note,
                ItemCount = p.Items.Count(),
                CreatedAt = p.CreatedAt,
                Items = p.Items
                    .OrderBy(i => i.Id)
                    .Select(i => new PlanItemDto
                    {
                        Id = i.Id,
                        TaskId = i.TaskId,
                        Title = i.Task!.Title,
                        CategoryName = i.Task.Category!.Name,
                        ImageUrl = i.Task.ImageUrl,
                        TaskStatus = i.Task.Status,
                        Minutes = i.Minutes
                    })
                    .ToList()
            })
            .FirstOrDefaultAsync()
            ?? throw new AppException(StatusCodes.Status404NotFound, "Không tìm thấy kế hoạch");
    }
}
