using Microsoft.EntityFrameworkCore;
using TaskReminder.Api.Data.Entities;

namespace TaskReminder.Api.Data;

/// <summary>
/// DbContext ánh xạ ĐÚNG tên bảng/cột trong db/01_schema.sql.
/// CSDL được tạo bằng script SQL (không dùng EF migration), nên cấu hình ở đây chỉ để EF hiểu cấu trúc.
/// </summary>
public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<Role> Roles => Set<Role>();
    public DbSet<User> Users => Set<User>();
    public DbSet<EmailOtp> EmailOtps => Set<EmailOtp>();
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<TaskItem> Tasks => Set<TaskItem>();
    public DbSet<Plan> Plans => Set<Plan>();
    public DbSet<PlanItem> PlanItems => Set<PlanItem>();

    /// <summary>
    /// Quy ước thời gian: mọi cột DATETIME2 lưu giờ UTC.
    /// - Khi ghi: DateTime giờ địa phương (Kind = Local) được đổi sang UTC.
    /// - Khi đọc: SQL Server không lưu "Kind", nên đánh dấu lại là UTC để JSON trả về có hậu tố "Z"
    ///   và app Flutter đổi đúng sang giờ Việt Nam (dùng cho DueDate, ReminderAt...).
    /// </summary>
    protected override void ConfigureConventions(ModelConfigurationBuilder configurationBuilder)
    {
        configurationBuilder.Properties<DateTime>().HaveConversion<UtcDateTimeConverter>();
        configurationBuilder.Properties<DateTime?>().HaveConversion<UtcDateTimeConverter>();
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Role>(e =>
        {
            e.ToTable("Roles");
            e.Property(x => x.Name).HasMaxLength(20).IsRequired();
            e.HasIndex(x => x.Name).IsUnique();
        });

        modelBuilder.Entity<User>(e =>
        {
            e.ToTable("Users");
            e.Property(x => x.Email).HasMaxLength(150).IsRequired();
            e.HasIndex(x => x.Email).IsUnique();
            e.Property(x => x.PasswordHash).HasMaxLength(200);
            e.Property(x => x.FullName).HasMaxLength(100).IsRequired();
            e.Property(x => x.AvatarUrl).HasMaxLength(300);
            e.Property(x => x.GoogleId).HasMaxLength(100);
            e.HasOne(x => x.Role).WithMany(r => r.Users)
                .HasForeignKey(x => x.RoleId).OnDelete(DeleteBehavior.NoAction);
        });

        modelBuilder.Entity<EmailOtp>(e =>
        {
            e.ToTable("EmailOtps");
            e.Property(x => x.CodeHash).HasMaxLength(200).IsRequired();
            e.Property(x => x.Purpose).HasMaxLength(20).IsRequired();
            e.HasOne(x => x.User).WithMany()
                .HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<Category>(e =>
        {
            e.ToTable("Categories");
            e.Property(x => x.Name).HasMaxLength(100).IsRequired();
            e.HasIndex(x => x.Name).IsUnique();
            e.Property(x => x.Description).HasMaxLength(500);
            e.Property(x => x.ImageUrl).HasMaxLength(300);
        });

        modelBuilder.Entity<TaskItem>(e =>
        {
            e.ToTable("Tasks");
            e.Property(x => x.Title).HasMaxLength(200).IsRequired();
            e.Property(x => x.Description).HasMaxLength(2000);
            e.Property(x => x.Status).HasMaxLength(10).IsRequired();
            e.Property(x => x.ImageUrl).HasMaxLength(300);
            e.HasOne(x => x.User).WithMany()
                .HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.NoAction);
            // NO ACTION: muốn xóa nhóm phải kiểm tra nhóm còn công việc không (trả 409)
            e.HasOne(x => x.Category).WithMany(c => c.Tasks)
                .HasForeignKey(x => x.CategoryId).OnDelete(DeleteBehavior.NoAction);
        });

        modelBuilder.Entity<Plan>(e =>
        {
            e.ToTable("Plans");
            e.Property(x => x.Status).HasMaxLength(15).IsRequired();
            e.Property(x => x.Note).HasMaxLength(500);
            e.HasOne(x => x.User).WithMany()
                .HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.NoAction);
        });

        modelBuilder.Entity<PlanItem>(e =>
        {
            e.ToTable("PlanItems");
            // CASCADE: xóa Plan thì xóa luôn các PlanItems
            e.HasOne(x => x.Plan).WithMany(p => p.Items)
                .HasForeignKey(x => x.PlanId).OnDelete(DeleteBehavior.Cascade);
            // NO ACTION: muốn xóa công việc phải kiểm tra công việc có trong kế hoạch không (trả 409)
            e.HasOne(x => x.Task).WithMany(t => t.PlanItems)
                .HasForeignKey(x => x.TaskId).OnDelete(DeleteBehavior.NoAction);
        });
    }
}

public class UtcDateTimeConverter : Microsoft.EntityFrameworkCore.Storage.ValueConversion.ValueConverter<DateTime, DateTime>
{
    public UtcDateTimeConverter() : base(
        v => v.Kind == DateTimeKind.Local ? v.ToUniversalTime() : v,
        v => DateTime.SpecifyKind(v, DateTimeKind.Utc))
    { }
}
