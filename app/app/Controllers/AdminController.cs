using app.Managers;
using app.Models;
using app.Repositories;
using app.Utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace app.Controllers;

[Authorize(Roles = "Admin")]
[Route("admin")]
public class AdminController : Controller
{
    private const int PolozekNaStranku = Constants.ResultPerPage * 4;

    private readonly IIdConverter _converter;
    private readonly UserManager _userManager;
    private readonly LogRepository _logRepository;

    public AdminController(IIdConverter converter, UserManager userManager, LogRepository logRepository)
    {
        _converter = converter;
        _userManager = userManager;
        _logRepository = logRepository;
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

        ViewBag.Tabulky = new[]
        {
            "",
            "zajezd",
            "objednavka",
            "strava"
        };

        ViewBag.Operace = new[]
        {
            "",
            "insert",
            "delete",
            "update",
            "create"
        };

        ViewBag.Strana = strana;
        ViewBag.MaxStrana = PocetStran(celkovyPocetRadku);

        return View(model);
    }

    [Route("prepnout/{id}")]
    public IActionResult PrepnoutUzivatele(string id)
    {
        _userManager.ChangeToUser(HttpContext, _converter.Decode(id));

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
        string uzivatelskeJmeno = "",
        string role = "",
        int strana = 1
    )
    {
        var maxStrana = 3;

        if (strana < 1 || strana > maxStrana)
            strana = 1;

        var model = new UzivatelModel[100];
        for (var i = 0; i < model.Length; i++)
        {
            model[i] = new UzivatelModel
            {
                Id = "iyovc",
                PrihlasovaciJmeno = $"pepa_{i}",
                Jmeno = "Pepa",
                Prijmeni = "Zdepa",
                Role = "Zakaznik"
            };
        }

        ViewBag.Role = new[]
        {
            "Všechny",
            "Zákazník",
            "Zaměstnanec",
            "Admin"
        };

        ViewBag.Strana = strana;
        ViewBag.MaxStrana = maxStrana;

        return View(model);
    }

    [HttpGet]
    [Route("uzivatele/{id}")]
    public IActionResult UzivatelEdit(string id)
    {
        ViewData["id"] = _converter.Decode(id);

        return View();
    }

    [HttpPost]
    [Route("uzivatele/{id}")]
    public IActionResult UzivatelEditPost(string id)
    {
        ViewData["id"] = _converter.Decode(id);

        return Ok();
    }

    [HttpDelete]
    [Route("uzivatele/{id}")]
    public IActionResult UzivatelDelete(string id)
    {
        ViewData["id"] = _converter.Decode(id);

        return Ok();
    }
}