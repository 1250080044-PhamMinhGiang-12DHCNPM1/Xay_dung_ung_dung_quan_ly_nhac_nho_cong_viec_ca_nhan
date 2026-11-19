using Microsoft.EntityFrameworkCore;

namespace TaskReminder.Api.Common;

/// <summary>
/// Kết quả phân trang: data = { items, page, pageSize, totalItems, totalPages }.
/// </summary>
public class PagedResult<T>
{
    public List<T> Items { get; set; } = new();
    public int Page { get; set; }
    public int PageSize { get; set; }
    public int TotalItems { get; set; }
    public int TotalPages { get; set; }
}

public static class Paging
{
    public const int DefaultPageSize = 10;
    public const int MaxPageSize = 50;

    /// <summary>
    /// Chuẩn hóa tham số phân trang: page tối thiểu 1, pageSize từ 1 đến 50 (mặc định 10).
    /// </summary>
    public static (int page, int pageSize) Normalize(int? page, int? pageSize)
    {
        int p = page is null or < 1 ? 1 : page.Value;
        int size = pageSize is null or < 1 ? DefaultPageSize : Math.Min(pageSize.Value, MaxPageSize);
        return (p, size);
    }

    /// <summary>
    /// Phân trang một câu truy vấn EF Core.
    /// Thuật toán: đếm tổng số dòng (COUNT), rồi bỏ qua (page - 1) * pageSize dòng đầu (Skip)
    /// và lấy pageSize dòng tiếp theo (Take). SQL Server dịch thành OFFSET ... FETCH NEXT.
    /// Query PHẢI có OrderBy trước khi gọi hàm này để thứ tự các trang ổn định.
    /// </summary>
    public static async Task<PagedResult<T>> ToPagedResultAsync<T>(this IQueryable<T> query, int? page, int? pageSize)
    {
        var (p, size) = Normalize(page, pageSize);
        int total = await query.CountAsync();
        var items = await query.Skip((p - 1) * size).Take(size).ToListAsync();
        return new PagedResult<T>
        {
            Items = items,
            Page = p,
            PageSize = size,
            TotalItems = total,
            // Làm tròn lên: 25 dòng, 10 dòng/trang => 3 trang
            TotalPages = (int)Math.Ceiling(total / (double)size)
        };
    }
}
