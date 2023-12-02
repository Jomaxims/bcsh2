using app.Managers;
using app.Models;
using app.Repositories;
using app.Utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace app.Controllers;

[Authorize(Policy = "Admin")]
[Route("admin")]
public class AdminController : Controller
{
    private const int PolozekNaStranku = Constants.ResultPerPage * 4;

    private readonly IIdConverter _converter;
    private readonly LogRepository _logRepository;
    private readonly DatabazoveObjektyRepository _databazoveObjektyRepository;
    private readonly UserManager _userManager;

    public AdminController(IIdConverter converter, UserManager userManager, LogRepository logRepository,
        DatabazoveObjektyRepository databazoveObjektyRepository)
    {
        _converter = converter;
        _userManager = userManager;
        _logRepository = logRepository;
        _databazoveObjektyRepository = databazoveObjektyRepository;
    }

    private int PocetStran(int pocetRadku, int polozekNaStranku = 0)
    {
        if (polozekNaStranku == 0)
            polozekNaStranku = PolozekNaStranku;

        return (int)Math.Ceiling((double)pocetRadku / polozekNaStranku);
    }

    [Route("logy")]
    public IActionResult Logy(
        string tabulka = "",
        string operace = "",
        DateOnly datumOd = default,
        DateOnly datumDo = default,
        int strana = 1
    )
    {
        if (strana < 1)
            strana = 1;

        var start = (strana - 1) * PolozekNaStranku;
        var model = _logRepository.GetAll(out var celkovyPocetRadku, tabulka, operace, datumOd, datumDo, start,
            PolozekNaStranku);

        ViewBag.Tabulky = _databazoveObjektyRepository.GetTabulky();

        ViewBag.Operace = new[]
        {
            "",
            "INSERT",
            "DELETE",
            "UPDATE"
        };

        ViewBag.Strana = strana;
        ViewBag.MaxStrana = PocetStran(celkovyPocetRadku);

        return View(model);
    }

    [Route("prepnout/{id}")]
    public IActionResult PrepnoutUzivatele(string id, string role)
    {
        _userManager.ChangeToUser(HttpContext, _converter.Decode(id), role);

        return RedirectToAction("Index", "Home");
    }

    [AllowAnonymous]
    [Route("prepnout-zpet")]
    public IActionResult PrepnoutZpet()
    {
        _userManager.ChangeFromUser(HttpContext);

        return RedirectToAction("Uzivatele");
    }

    [Route("uzivatele")]
    public IActionResult Uzivatele(
        string jmeno = "",
        string prihlasovaciJmeno = "",
        string role = "",
        int strana = 1
    )
    {
        if (strana < 1)
            strana = 1;

        var start = (strana - 1) * PolozekNaStranku;
        var model = _userManager.GetAllUsers(out var celkovyPocetRadku, jmeno, prihlasovaciJmeno, role, start,
            PolozekNaStranku);

        ViewBag.Role = new[]
        {
            "",
            "Zákazník",
            "Zaměstnanec",
            "Admin"
        };

        ViewBag.Strana = strana;
        ViewBag.MaxStrana = PocetStran(celkovyPocetRadku);

        return View(model);
    }

    [Route("db-objekty")]
    public IActionResult DbObjekty()
    {
        var model = new DbObjektyModel
        {
            Tabulky = _databazoveObjektyRepository.GetTabulky(),
            Pohledy = _databazoveObjektyRepository.GetPohledy(),
            Indexy = _databazoveObjektyRepository.GetIndexy(),
            Package = _databazoveObjektyRepository.GetPackage(),
            Procedury = _databazoveObjektyRepository.GetProcedury(),
            Funkce = _databazoveObjektyRepository.GetFunkce(),
            Triggery = _databazoveObjektyRepository.GetTriggry()
        };
        
        return View(model);
    }
}