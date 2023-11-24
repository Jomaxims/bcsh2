using app.Managers;
using app.Models;
using app.Utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace app.Controllers;

[Authorize(Roles = "Admin")]
[Route("admin")]
public class AdminController : Controller
{
    private readonly IIdConverter _converter;
    private readonly UserManager _userManager;

    public AdminController(IIdConverter converter, UserManager userManager)
    {
        _converter = converter;
        _userManager = userManager;
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
        var maxStrana = 3;
        
        if (datumOd < DateOnly.FromDateTime(DateTime.Today))
            datumOd = DateOnly.FromDateTime(DateTime.Today);
        if (datumDo == default)
            datumDo = DateOnly.MaxValue;
        if (strana < 1 || strana > maxStrana)
            strana = 1;
        
        var model = new LogModel[100];
        for (var i = 0; i < model.Length; i++)
        {
            model[i] = new LogModel
            {
                Tabulka = $"Zajezdy",
                Operace = "Insert",
                CasZmeny = DateTime.Now,
                Uzivatel = "Pepa",
                Pred = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed eget luctus risus. Aliquam erat volutpat. Proin eget efficitur dolor. In interdum sapien libero, et dignissim ante consequat sollicitudin. Sed lobortis eu dui vehicula aliquam. Sed eget posuere ipsum. Quisque ac erat venenatis, venenatis nisi sit amet, mollis ex. In eu tortor augue. Suspendisse rutrum sagittis turpis, a volutpat tellus pulvinar vitae. Suspendisse vehicula felis tellus,",
                Po = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed eget luctus risus. Aliquam erat volutpat. Proin eget efficitur dolor. In interdum sapien libero, et dignissim ante consequat sollicitudin. Sed lobortis eu dui vehicula aliquam. Sed eget posuere ipsum. Quisque ac erat venenatis, venenatis nisi sit amet, mollis ex. In eu tortor augue. Suspendisse rutrum sagittis turpis, a volutpat tellus pulvinar vitae. Suspendisse vehicula felis tellus,"
            };
        }

        ViewBag.Tabulky = new[]
        {
            "Všechny",
            "zajezd",
            "objednavka",
            "strava"
        };
        
        ViewBag.Operace = new[]
        {
            "Všechny",
            "insert",
            "delete",
            "update",
            "create"
        };

        ViewBag.Strana = strana;
        ViewBag.MaxStrana = maxStrana;
        
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