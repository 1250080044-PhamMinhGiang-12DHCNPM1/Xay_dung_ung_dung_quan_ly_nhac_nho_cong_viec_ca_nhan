namespace TaskReminder.Api.Common;

/// <summary>
/// Dạng response chuẩn cho MỌI API: { success, message, data }.
/// </summary>
public class ApiResponse<T>
{
    public bool Success { get; set; }
    public string Message { get; set; } = "";
    public T? Data { get; set; }

    public static ApiResponse<T> Ok(T? data, string message = "") =>
        new() { Success = true, Message = message, Data = data };
}

/// <summary>Hàm tiện ích cho response không có data (data = null).</summary>
public static class ApiResponse
{
    public static ApiResponse<object> Ok(string message = "") =>
        new() { Success = true, Message = message };

    public static ApiResponse<object> Fail(string message) =>
        new() { Success = false, Message = message };
}
