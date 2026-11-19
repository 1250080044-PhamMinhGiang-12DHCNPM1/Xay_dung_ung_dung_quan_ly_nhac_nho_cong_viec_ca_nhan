using System.Text.Encodings.Web;
using System.Text.Json;

namespace TaskReminder.Api.Common;

/// <summary>
/// Bắt mọi exception trong pipeline và trả về dạng { success:false, message, data:null }.
/// - AppException: dùng đúng StatusCode và message của lỗi nghiệp vụ.
/// - Lỗi khác: trả 500, ghi log chi tiết, không lộ thông tin nội bộ cho client.
/// </summary>
public class ErrorHandlingMiddleware
{
    // Giữ nguyên tiếng Việt trong JSON (không đổi thành ạ...)
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web)
    {
        Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping
    };

    private readonly RequestDelegate _next;
    private readonly ILogger<ErrorHandlingMiddleware> _logger;

    public ErrorHandlingMiddleware(RequestDelegate next, ILogger<ErrorHandlingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (AppException ex)
        {
            await WriteErrorAsync(context, ex.StatusCode, ex.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Lỗi không xử lý được: {Path}", context.Request.Path);
            await WriteErrorAsync(context, StatusCodes.Status500InternalServerError, "Lỗi hệ thống, vui lòng thử lại sau");
        }
    }

    public static async Task WriteErrorAsync(HttpContext context, int statusCode, string message)
    {
        if (context.Response.HasStarted) return;
        context.Response.StatusCode = statusCode;
        context.Response.ContentType = "application/json; charset=utf-8";
        var body = JsonSerializer.Serialize(ApiResponse.Fail(message), JsonOptions);
        await context.Response.WriteAsync(body);
    }
}
