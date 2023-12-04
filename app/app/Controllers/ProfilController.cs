using System.Security.Claims;
using app.Managers;
using app.Models;
using app.Models.Sprava;
using app.Repositories;
using app.Utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace app.Controllers;

[Authorize(Policy = "Zakaznik")]
public class ProfilController : Controller
{
    private readonly IIdConverter _idConverter;
    private readonly ObjednavkaRepository _objednavkaRepository;
    private readonly PrihlasovaciUdajeRepository _prihlasovaciUdajeRepository;
    private readonly UserManager _userManager;
    private readonly ZakaznikRepository _zakaznikRepository;

    public ProfilController(ZakaznikRepository zakaznikRepository, ObjednavkaRepository objednavkaRepository,
        IIdConverter idConverter, UserManager userManager, PrihlasovaciUdajeRepository prihlasovaciUdajeRepository)
    {
        _zakaznikRepository = zakaznikRepository;
        _objednavkaRepository = objednavkaRepository;
        _idConverter = idConverter;
        _userManager = userManager;
        _prihlasovaciUdajeRepository = prihlasovaciUdajeRepository;
    }

    [Route("profil")]
    public IActionResult Profil()
    {
        var zakaznikId = int.Parse(User.Claims.First(claim => claim.Type == ClaimTypes.NameIdentifier).Value);
        var model = new ProfilModel
        {
            Zakaznik = _zakaznikRepository.Get(zakaznikId),
            Objednavky = _objednavkaRepository.GetObjednavkyZakaznika(zakaznikId)
        };

        return View(model);
    }

    [HttpPost]
    [Route("profil/udaje")]
    public IActionResult UdajePost([FromForm] ZakaznikModel model)
    {
        var zakaznikId = int.Parse(User.Claims.First(claim => claim.Type == ClaimTypes.NameIdentifier).Value);

        model.ZakaznikId = _idConverter.Encode(zakaznikId);
        model.PrihlasovaciUdaje = new PrihlasovaciUdajeModel
        {
            PrihlasovaciUdajeId = model.PrihlasovaciUdaje.PrihlasovaciUdajeId
        };

        _zakaznikRepository.AddOrEdit(model);

        return RedirectToAction("Profil");
    }

    [HttpPost]
    [Route("profil/heslo")]
    public IActionResult HesloPost([FromForm] string heslo)
    {
        var zakaznikId = int.Parse(User.Claims.First(claim => claim.Type == ClaimTypes.NameIdentifier).Value);

        _zakaznikRepository.ZmenHesloZakaznika(zakaznikId, heslo);

        return RedirectToAction("Profil");
    }

    [AllowAnonymous]
    [HttpGet]
    [Route("registrace")]
    public IActionResult Register()
    {
        return View();
    }

    [AllowAnonymous]
    [HttpPost]
    [Route("registrace")]
    public IActionResult RegisterPost(ZakaznikModel model)
    {
        if (_prihlasovaciUdajeRepository.UzivatelExistuje(model.PrihlasovaciUdaje.Jmeno))
            return RedirectToAction("RegisterChyba");

        _zakaznikRepository.AddOrEdit(model);

        return RedirectToAction("Login");
    }

    [AllowAnonymous]
    [HttpGet]
    [Route("registrace/chyba")]
    public IActionResult RegisterChyba()
    {
        return View();
    }

    [AllowAnonymous]
    [HttpGet]
    [Route("login")]
    public IActionResult Login(string chyba)
    {
        ViewBag.Chyba = chyba;
        return View();
    }

    [AllowAnonymous]
    [HttpPost]
    [Route("login")]
    public IActionResult LoginPost(LoginModel? model)
    {
        if (!(ModelState.IsValid && model != null))
            return BadRequest();

        var res = _userManager.Login(HttpContext, model.Jmeno, model.Heslo);

        return res ? RedirectToAction("Index", "Home") : RedirectToAction("Login", new { chyba = "Nepodařilo se přihlásit" });
    }

    [AllowAnonymous]
    [HttpGet]
    [Route("logout")]
    public IActionResult Logout()
    {
        _userManager.Logout(HttpContext);

        return RedirectToAction("Index", "Home");
    }
}