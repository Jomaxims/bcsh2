using System.Data;
using System.Security.Claims;
using app.DAL;
using app.Models;
using app.Utils;
using Dapper;
using Dapper.Oracle;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;

namespace app.Managers;

public class Role
{
    public static string Zakaznik = "Zákazník";
    public static string Zamestnanec = "Zaměstnanec";
    public static string Admin = "Admin";
}

/// <summary>
/// Třída pro přihlašování, odhlašování a přepínání uživatelů
/// </summary>
public class UserManager
{
    private readonly IDbUnitOfWork _unitOfWork;
    private readonly IIdConverter _idConverter;

    public UserManager(IDbUnitOfWork unitOfWork, IIdConverter idConverter)
    {
        _unitOfWork = unitOfWork;
        _idConverter = idConverter;
    }

    /// <summary>
    /// Přihlásí uživatel do kontextu pomocí cookies
    /// </summary>
    /// <param name="context"></param>
    /// <param name="name">Přihlašovací jméno</param>
    /// <param name="password">Heslo</param>
    /// <returns></returns>
    public bool Login(HttpContext context, string name, string password)
    {
        var parameters = new OracleDynamicParameters();
        parameters.Add("p_usr_name", name);
        parameters.Add("p_usr_pwd", password);

        parameters.Add("p_cursor", null, OracleMappingType.RefCursor, ParameterDirection.Output);

        var row = _unitOfWork.Connection.QuerySingleOrDefault<dynamic?>("pck_Security.login", parameters,
            commandType: CommandType.StoredProcedure);

        if (row == null)
            return false;

        var uzivatelId = row.UZIVATEL_ID.ToString();
        var role = (string)row.ROLE;

        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, uzivatelId),
            new(ClaimTypes.Role, role)
        };

        if (role == Role.Admin)
        {
            claims.Add(new Claim(ClaimTypes.Role, Role.Zamestnanec));
        }

        var identity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
        var principal = new ClaimsPrincipal(identity);

        context.SignInAsync(
            CookieAuthenticationDefaults.AuthenticationScheme, principal,
            new AuthenticationProperties { IsPersistent = true }
        );

        return true;
    }

    /// <summary>
    /// Získá všechny uživatele dle filtrů pro sprvábu uživatelů
    /// </summary>
    /// <param name="celkovyPocetRadku">Celkový počet řádků</param>
    /// <param name="jmeno">Celé jméno</param>
    /// <param name="prihlasovaciJmeno">Přihlašovací jméno</param>
    /// <param name="role">Role</param>
    /// <param name="start">První řádek stránkování</param>
    /// <param name="pocetRadku">Počet položek</param>
    /// <returns></returns>
    public IEnumerable<UzivatelModel> GetAllUsers(out int celkovyPocetRadku, string jmeno = "",
        string prihlasovaciJmeno = "", string role = "", int start = 0, int pocetRadku = 0)
    {
        var sql = $"""
                       select uzivatel_id, cele_jmeno, prihlasovaci_jmeno, role, count(*) over () as pocet_radku
                       from uzivatel_view
                       /**where**/
                       order by cele_jmeno
                       offset {start} rows fetch next {pocetRadku} rows only
                   """;
        var builder = new SqlBuilder();
        var template = builder.AddTemplate(sql);
        if (jmeno != "")
            builder.Where("LOWER(cele_jmeno) like :jmeno", new { jmeno = $"%{jmeno.ToLower()}%" });
        if (prihlasovaciJmeno != "")
            builder.Where("LOWER(prihlasovaci_jmeno) like :prihlasovaciJmeno", new { prihlasovaciJmeno = $"%{prihlasovaciJmeno.ToLower()}%" });
        if (role != "")
            builder.Where("role = :role", new { role });

        var rows = _unitOfWork.Connection.Query<dynamic>(template.RawSql, template.Parameters);

        var model = rows.Select(row =>
        {
            var user = new UzivatelModel
            {
                UzivatelId = _idConverter.Encode((int)row.UZIVATEL_ID),
                Jmeno = row.CELE_JMENO,
                PrihlasovaciJmeno = row.PRIHLASOVACI_JMENO,
                Role = row.ROLE
            };

            return user;
        });

        celkovyPocetRadku = Convert.ToInt32(rows.FirstOrDefault()?.CELKOVY_POCET_VYSLEDKU ?? 0);
        return model;
    }

    /// <summary>
    /// Odhlásí uživatele z kontextu
    /// </summary>
    /// <param name="context"></param>
    public void Logout(HttpContext context)
    {
        context.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
    }

    /// <summary>
    /// Získá id přihlášeného uživatele
    /// </summary>
    /// <param name="context"></param>
    /// <returns></returns>
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

    /// <summary>
    /// Přepne uživatele
    /// </summary>
    /// <param name="context"></param>
    /// <param name="userId">id nového uživatele</param>
    /// <param name="role">role uživatele</param>
    public void ChangeToUser(HttpContext context, int userId, string role)
    {
        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, userId.ToString()),
            new(ClaimTypes.Role, role),
            new("OriginalUser", GetCurrentUserId(context).ToString() ?? "")
        };

        if (role == Role.Admin)
        {
            claims.Add(new Claim(ClaimTypes.Role, Role.Zamestnanec));
        }

        var identity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
        var principal = new ClaimsPrincipal(identity);

        context.SignInAsync(
            CookieAuthenticationDefaults.AuthenticationScheme, principal,
            new AuthenticationProperties { IsPersistent = true }
        );
    }

    /// <summary>
    /// Přepne zpět z uživatele
    /// </summary>
    /// <param name="context"></param>
    /// <exception cref="ArgumentNullException"></exception>
    public void ChangeFromUser(HttpContext context)
    {
        var originalUser = context.User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value ??
                           throw new ArgumentNullException();
        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, originalUser),
            new(ClaimTypes.Role, Role.Admin),
            new(ClaimTypes.Role, Role.Zamestnanec)
        };

        var identity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
        var principal = new ClaimsPrincipal(identity);

        context.SignInAsync(
            CookieAuthenticationDefaults.AuthenticationScheme, principal,
            new AuthenticationProperties { IsPersistent = true }
        );
    }
}