using System.Security.Claims;
using app.Models;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;

namespace app.Managers;

public class Role
{
    public static string Zakaznik = "zakaznik";
    public static string Zamestnanec = "zamestnanec";
    public static string Admin = "admin";
}

public class User
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Role { get; set; }
}

public interface IUserManager
{
    void SignUp(SignUpViewModel user);
    bool Login(HttpContext context, string name, string password);
    void Logout(HttpContext context);
    int? GetCurrentUserId(HttpContext context);
    User? GetCurrentUser(HttpContext context);
}

public class UserManager
{
    public void SignUp(SignUpViewModel user)
    {
        
    }

    public bool Login(HttpContext context, string name, string password)
    {
        if (!(name == "admin" && password == "admin"))
            return false;
        
        var claims = new List<Claim>();
        claims.Add(new Claim(ClaimTypes.NameIdentifier, "1"));
        claims.Add(new Claim(ClaimTypes.Name, name));
        claims.Add(new Claim(ClaimTypes.Role, Role.Admin));
        
        var identity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
        var principal = new ClaimsPrincipal(identity);

        context.SignInAsync(
            CookieAuthenticationDefaults.AuthenticationScheme, principal, new AuthenticationProperties() { IsPersistent = true }
        );

        return true;
    }

    public void Logout(HttpContext context)
    {
        context.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
    }

    public int? GetCurrentUserId(HttpContext context)
    {
        if (!context.User.Identity!.IsAuthenticated)
            return null;

        var claim = context.User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier);

        if (claim == null)
            return null;
        
        if (!int.TryParse(claim.Value, out var currentUserId))
            return null;

        return currentUserId;
    }

    public User? GetCurrentUser(HttpContext context)
    {
        var currentUserId = GetCurrentUserId(context);

        if (currentUserId == null)
            return null;

        return new User { Id = currentUserId.Value, Name = "pepa", Role = "pepa"};
    }
}