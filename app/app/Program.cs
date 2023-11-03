using app.DAL;
using app.DAL.Repositories;
using app.Managers;
using Microsoft.AspNetCore.Authentication.Cookies;
using Sqids;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddSingleton(new SqidsEncoder<int>(new SqidsOptions
{
    Alphabet = "shQpZVOxoN3nv1guIT8RHXwf0eqaWyjzBdkLScbPDMJUt24F7C9m5K6rlEGiYA",
    MinLength = 5,
}));
builder.Services.AddSingleton<IDbConnectionFactory, DbConnectionFactory>();
builder.Services.AddSingleton<DatabaseManager, DatabaseManager>();

builder.Services.AddScoped<IDbUnitOfWork, DbUnitOfWork>();
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<UserManager, UserManager>();

builder.Services.AddRazorPages();
builder.Services.AddControllersWithViews();
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
        {
            options.ExpireTimeSpan = TimeSpan.FromDays(7);
        }
    );
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("Zamestnanec", policy => policy.RequireRole(Role.Admin, Role.Zamestnanec));
    options.AddPolicy("Zakaznik", policy => policy.RequireRole(Role.Zakaznik));
    options.AddPolicy("Vsichni", policy => policy.RequireRole(Role.Admin, Role.Zamestnanec, Role.Zakaznik));
});

var app = builder.Build();

// app.Services.GetService<DatabaseManager>()?.CreateTables();
// app.Services.GetService<DatabaseManager>()?.TestProcedure();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}
else
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();
app.MapControllers();
app.MapRazorPages();

app.Run();