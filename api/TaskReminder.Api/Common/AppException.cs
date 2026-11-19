namespace TaskReminder.Api.Common;

/// <summary>
/// Lỗi nghiệp vụ có kèm mã HTTP. Service ném lỗi này, middleware sẽ đổi thành response chuẩn.
/// Ví dụ: throw new AppException(409, "Email đã được sử dụng").
/// </summary>
public class AppException : Exception
{
    public int StatusCode { get; }

    public AppException(int statusCode, string message) : base(message)
    {
        StatusCode = statusCode;
    }
}
