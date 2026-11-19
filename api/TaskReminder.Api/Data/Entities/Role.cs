namespace TaskReminder.Api.Data.Entities;

/// <summary>Bảng Roles: Admin, Member.</summary>
public class Role
{
    public const string Admin = "Admin";
    public const string Member = "Member";

    public int Id { get; set; }
    public string Name { get; set; } = "";

    public List<User> Users { get; set; } = new();
}
