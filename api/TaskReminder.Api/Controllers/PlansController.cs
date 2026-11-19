using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TaskReminder.Api.Common;
using TaskReminder.Api.DTOs;
using TaskReminder.Api.Services;

namespace TaskReminder.Api.Controllers;

/// <summary>Kế hoạch của tôi: chốt kế hoạch, lịch sử, chi tiết. UserId lấy từ JWT.</summary>
[ApiController]
[Route("api/plans")]
[Authorize]
public class PlansController : ControllerBase
{
    private readonly PlanService _plans;

    public PlansController(PlanService plans)
    {
        _plans = plans;
    }

    /// <summary>POST /api/plans  body: {planDate: "yyyy-MM-dd", note, items:[{taskId, minutes}]}</summary>
    [HttpPost]
    public async Task<ActionResult<ApiResponse<PlanDetailDto>>> Create(CreatePlanRequest req)
    {
        var plan = await _plans.CreateAsync(User.GetUserId(), req);
        return StatusCode(StatusCodes.Status201Created, ApiResponse<PlanDetailDto>.Ok(plan, "Đã chốt kế hoạch"));
    }

    /// <summary>GET /api/plans?keyword&amp;page&amp;pageSize</summary>
    [HttpGet]
    public async Task<ActionResult<ApiResponse<PagedResult<PlanSummaryDto>>>> GetMyPlans(
        [FromQuery] string? keyword, [FromQuery] int? page, [FromQuery] int? pageSize)
    {
        var result = await _plans.GetMyPlansAsync(User.GetUserId(), keyword, page, pageSize);
        return Ok(ApiResponse<PagedResult<PlanSummaryDto>>.Ok(result));
    }

    /// <summary>GET /api/plans/{id}</summary>
    [HttpGet("{id:int}")]
    public async Task<ActionResult<ApiResponse<PlanDetailDto>>> GetDetail(int id)
    {
        return Ok(ApiResponse<PlanDetailDto>.Ok(await _plans.GetDetailAsync(User.GetUserId(), id)));
    }
}
