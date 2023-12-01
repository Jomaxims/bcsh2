using System.Net.Mime;
using app.DAL;
using app.Managers;
using app.Repositories;
using app.Utils;
using Dapper;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Diagnostics;
using Sqids;

SqlMapper.AddTypeHandler(new DapperSqlDateOnlyTypeHandler());
DefaultTypeMap.MatchNamesWithUnderscores = true;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddSingleton<IIdConverter>(new IdConverter(
    new SqidsEncoder<int>(
        new SqidsOptions
        {
            Alphabet = "shQpZVOxoN3nv1guIT8RHXwf0eqaWyjzBdkLScbPDMJUt24F7C9m5K6rlEGiYA",
            MinLength = 5
        }
    )));
builder.Services.AddSingleton<IDbConnectionFactory, DbConnectionFactory>();
builder.Services.AddSingleton<DatabaseManager, DatabaseManager>();
builder.Services.AddScoped(typeof(GenericDao<>), typeof(GenericDao<>));

var repos = typeof(BaseRepository).Assembly.GetTypes().Where(t => t.BaseType == typeof(BaseRepository));
foreach (var repo in repos) builder.Services.AddScoped(repo, repo);

builder.Services.AddScoped<IDbUnitOfWork, DbUnitOfWork>();
builder.Services.AddScoped<UserManager, UserManager>();

builder.Services.AddRazorPages();
builder.Services.AddControllersWithViews();
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options => { options.ExpireTimeSpan = TimeSpan.FromDays(7); }
    );
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("Zamestnanec", policy => policy.RequireRole(Role.Admin, Role.Zamestnanec));
    options.AddPolicy("Zakaznik", policy => policy.RequireRole(Role.Zakaznik));
    options.AddPolicy("Vsichni", policy => policy.RequireRole(Role.Admin, Role.Zamestnanec, Role.Zakaznik));
});
if (builder.Environment.IsDevelopment()) builder.Services.AddSassCompiler(); // TODO

var app = builder.Build();

// Configure the HTTP request pipeline.
if (false)
{
    app.UseDeveloperExceptionPage();
}

// app.UseExceptionHandler("/Home/Error");
app.UseExceptionHandler(exemptionApp =>
{
    exemptionApp.Run(async context =>
    {
        var exceptionHandler = context.Features.Get<IExceptionHandlerPathFeature>();

        var chyba = exceptionHandler?.Error switch
        {
            InvalidIdException => "Položka neexistuje",
            DatabaseException => exceptionHandler.Error.Message,
            _ => "Chyba aplikace"
        };

        context.Response.Redirect($"/error?chyba={chyba}");
    });
});
// The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
app.UseHsts();

// app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseStatusCodePages(MediaTypeNames.Text.Plain, "Status Code Page: {0}");
app.UseRouting();

app.UseAuthorization();
app.MapControllers();
app.MapRazorPages();

app.Run();