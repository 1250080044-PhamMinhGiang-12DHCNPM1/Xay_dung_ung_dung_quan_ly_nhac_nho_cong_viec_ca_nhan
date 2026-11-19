using TaskReminder.Api.Common;

namespace TaskReminder.Api.Services;

/// <summary>
/// Dịch vụ lưu/xóa ảnh dùng chung cho Category (Bảo) và Task (Hiếu).
/// Ảnh lưu tại wwwroot/uploads/&lt;folder&gt;/&lt;guid&gt;.&lt;ext&gt;, trả về url dạng /uploads/&lt;folder&gt;/&lt;guid&gt;.&lt;ext&gt;.
/// Cách dùng:
///   Thêm:  entity.ImageUrl = await _files.SaveImageAsync(image, FileService.FolderTasks);
///   Sửa:   có ảnh mới → lưu ảnh mới, rồi _files.DeleteFile(urlCũ)
///   Xóa:   _files.DeleteFile(entity.ImageUrl)
/// </summary>
public class FileService
{
    public const string FolderCategories = "categories";
    public const string FolderTasks = "tasks";

    private const long MaxSizeBytes = 5 * 1024 * 1024; // 5 MB
    private static readonly string[] AllowedExtensions = { ".jpg", ".jpeg", ".png", ".webp" };
    private static readonly string[] AllowedFolders = { FolderCategories, FolderTasks };

    private readonly string _uploadsRoot;

    public FileService(IWebHostEnvironment env)
    {
        var webRoot = env.WebRootPath ?? Path.Combine(env.ContentRootPath, "wwwroot");
        _uploadsRoot = Path.GetFullPath(Path.Combine(webRoot, "uploads"));
    }

    /// <summary>
    /// Kiểm tra và lưu ảnh. Ném AppException(400) nếu sai đuôi, rỗng hoặc quá 5 MB.
    /// </summary>
    public async Task<string> SaveImageAsync(IFormFile file, string folder)
    {
        if (!AllowedFolders.Contains(folder))
            throw new ArgumentException($"Thư mục upload không hợp lệ: {folder}");
        if (file.Length == 0)
            throw new AppException(StatusCodes.Status400BadRequest, "File ảnh rỗng");
        if (file.Length > MaxSizeBytes)
            throw new AppException(StatusCodes.Status400BadRequest, "Ảnh tối đa 5 MB");

        var ext = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (!AllowedExtensions.Contains(ext))
            throw new AppException(StatusCodes.Status400BadRequest, "Chỉ nhận ảnh jpg, jpeg, png, webp");

        // Tên file = Guid để không trùng và không lộ tên gốc của người dùng
        var fileName = $"{Guid.NewGuid()}{ext}";
        var dir = Path.Combine(_uploadsRoot, folder);
        Directory.CreateDirectory(dir);

        await using (var stream = new FileStream(Path.Combine(dir, fileName), FileMode.Create))
        {
            await file.CopyToAsync(stream);
        }
        return $"/uploads/{folder}/{fileName}";
    }

    /// <summary>
    /// Xóa file theo url (/uploads/...). Url rỗng hoặc file không tồn tại thì bỏ qua.
    /// </summary>
    public void DeleteFile(string? url)
    {
        if (string.IsNullOrWhiteSpace(url) || !url.StartsWith("/uploads/")) return;

        var relative = url["/uploads/".Length..].Replace('/', Path.DirectorySeparatorChar);
        var fullPath = Path.GetFullPath(Path.Combine(_uploadsRoot, relative));
        // Chống path traversal (vd: /uploads/../appsettings.json): chỉ xóa file nằm trong thư mục uploads
        if (!fullPath.StartsWith(_uploadsRoot + Path.DirectorySeparatorChar)) return;

        if (File.Exists(fullPath)) File.Delete(fullPath);
    }
}
