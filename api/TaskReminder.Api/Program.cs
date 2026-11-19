using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using TaskReminder.Api.Common;
using TaskReminder.Api.Data;
using TaskReminder.Api.Data.Entities;
using TaskReminder.Api.Services;

var builder = WebApplication.CreateBuilder(args);
var config = builder.Configuration;

// ---------- CSDL SQL Server ----------
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(config.GetConnectionString("Default")));

// ---------- Services (nghiệp vụ) ----------
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<UserService>();
builder.Services.AddSingleton<FileService>();
// Bảo / Hiếu / An đăng ký thêm CategoryService, TaskService, PlanService, EmailService ở đây.

// ---------- Controllers + validate ----------
builder.Services.AddControllers()
    .ConfigureApiBehaviorOptions(options =>
    {
        // Dữ liệu gửi lên sai (DataAnnotations) → 400 theo dạng chuẩn { success:false, message, data:null }
        options.InvalidModelStateResponseFactory = context =>
        {
            // Body không phải JSON hợp lệ: lỗi nằm ở key bắt đầu bằng "$" (đường dẫn JSON)
            if (context.ModelState.Keys.Any(k => k.StartsWith('$')))
                return new BadRequestObjectResult(ApiResponse.Fail("Dữ liệu gửi lên không đúng định dạng JSON"));

            var firstError = context.ModelState.Values
                .SelectMany(v => v.Errors)
                .Select(e => e.ErrorMessage)
                .FirstOrDefault(m => !string.IsNullOrWhiteSpace(m)) ?? "Dữ liệu không hợp lệ";
            return new BadRequestObjectResult(ApiResponse.Fail(firstError));
        };
    });

// ---------- Xác thực JWT ----------
var jwtKey = config["Jwt:Key"];
if (string.IsNullOrEmpty(jwtKey) || jwtKey.Length < 32)
    throw new InvalidOperationException("Thiếu Jwt:Key (tối thiểu 32 ký tự) trong appsettings.Development.json");

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        // Giữ nguyên tên claim trong token ("sub", "role"...), không đổi sang tên dài của .NET
        options.MapInboundClaims = false;
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = config["Jwt:Issuer"],
            ValidateAudience = true,
            ValidAudience = config["Jwt:Audience"],
            ValidateIssuerSigningKey = true, // kiểm tra chữ ký → token bị sửa sẽ không hợp lệ
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
            ValidateLifetime = true,         // kiểm tra exp → token hết hạn trả 401
            ClockSkew = TimeSpan.FromMinutes(1),
            RoleClaimType = "role",          // [Authorize(Roles = "Admin")] đọc claim "role"
            NameClaimType = "name"
        };

        options.Events = new JwtBearerEvents
        {
            // Token hợp lệ về chữ ký nhưng vẫn kiểm tra DB: tài khoản bị khóa hoặc đã bị đổi role
            // thì token cũ không dùng được nữa (bắt đăng nhập lại để lấy token mới).
            OnTokenValidated = async context =>
            {
                var db = context.HttpContext.RequestServices.GetRequiredService<AppDbContext>();
                var userId = int.TryParse(context.Principal?.FindFirst("sub")?.Value, out var id) ? id : 0;
                var tokenRole = context.Principal?.FindFirst("role")?.Value;
                var user = await db.Users.AsNoTracking()
                    .Where(u => u.Id == userId)
                    .Select(u => new { u.IsLocked, RoleName = u.Role!.Name })
                    .FirstOrDefaultAsync();

                if (user == null) context.Fail("Tài khoản không tồn tại");
                else if (user.IsLocked) context.Fail("Tài khoản đã bị khóa");
                else if (user.RoleName != tokenRole) context.Fail("Quyền đã thay đổi, vui lòng đăng nhập lại");
            },
            // 401: chưa đăng nhập / token sai / hết hạn → trả body chuẩn thay vì body rỗng
            OnChallenge = async context =>
            {
                context.HandleResponse();
                var message = context.AuthenticateFailure?.Message switch
                {
                    { } m when m.Contains("khóa") || m.Contains("Quyền") || m.Contains("tồn tại") => m,
                    { } m when m.Contains("expired") => "Phiên đăng nhập đã hết hạn",
                    _ => "Bạn chưa đăng nhập"
                };
                await ErrorHandlingMiddleware.WriteErrorAsync(context.HttpContext, StatusCodes.Status401Unauthorized, message);
            },
            // 403: đã đăng nhập nhưng không đủ quyền (vd Member gọi API Admin)
            OnForbidden = context =>
                ErrorHandlingMiddleware.WriteErrorAsync(context.HttpContext, StatusCodes.Status403Forbidden,
                    "Bạn không có quyền thực hiện chức năng này")
        };
    });
builder.Services.AddAuthorization();

// ---------- CORS cho phát triển ----------
builder.Services.AddCors(options =>
    options.AddDefaultPolicy(p => p.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod()));

// ---------- OpenAPI ----------
builder.Services.AddOpenApi();

var app = builder.Build();

// Seed role + tài khoản mẫu (bỏ qua nếu chưa kết nối được SQL Server, API vẫn chạy để xem lỗi)
using (var scope = app.Services.CreateScope())
{
    try
    {
        await DbSeeder.SeedAsync(scope.ServiceProvider.GetRequiredService<AppDbContext>());
    }
    catch (Exception ex)
    {
        app.Logger.LogError(ex, "Không seed được dữ liệu. Đã chạy db/01_schema.sql và sửa chuỗi kết nối chưa?");
    }
}

app.UseMiddleware<ErrorHandlingMiddleware>();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();                                  // /openapi/v1.json
    app.UseSwaggerUI(o => o.SwaggerEndpoint("/openapi/v1.json", "TaskReminder API")); // /swagger
}

app.UseStaticFiles(); // phục vụ ảnh /uploads/... từ wwwroot
app.UseCors();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
