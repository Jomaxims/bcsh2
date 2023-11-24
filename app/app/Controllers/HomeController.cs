using System.Diagnostics;
using app.DAL;
using app.DAL.Models;
using app.Managers;
using Microsoft.AspNetCore.Mvc;
using app.Models;

namespace app.Controllers;

public class HomeController : Controller
{
    private readonly ILogger<HomeController> _logger;
    private readonly UserManager _userManager;
    private readonly IDbUnitOfWork _unitOfWork;
    private readonly GenericDao<Adresa> _adresaDao;

    public HomeController(ILogger<HomeController> logger, UserManager userManager, IDbUnitOfWork unitOfWork, GenericDao<Adresa> adresaDao)
    {
        _logger = logger;
        _userManager = userManager;
        _unitOfWork = unitOfWork;
        _adresaDao = adresaDao;
    }

    [Route("")]
    public IActionResult Index()
    {
        var specilaniNabidky = new List<SpecialniNabidkaModel>();
        for (var i = 0; i < 5; i++)
        {
            specilaniNabidky.Add(new SpecialniNabidkaModel {FotoId = "1", Nazev = $"Nabídka {i}", Id = "jkMvT"});
        }
        
        return View(specilaniNabidky);
    }

    [Route("kontakt")]
    public IActionResult Kontakt()
    {
        return BadRequest();
    }
    
    [HttpGet]
    [Route("register")]
    public IActionResult Register()
    {
        return View();
    }
    
    [HttpPost]
    [Route("register")]
    public IActionResult RegisterPost(RegistraceModel? model)
    {
        if (!(ModelState.IsValid && model != null))
            return BadRequest();
        
        return View(model);
    }
    
    [HttpGet]
    [Route("login")]
    public IActionResult Login()
    {
        return View();
    }
    
    [HttpPost]
    [Route("login")]
    public IActionResult LoginPost(LoginModel? model)
    {
        if (!(ModelState.IsValid && model != null))
            return BadRequest();
        
        var res = _userManager.Login(HttpContext, model.Jmeno, model.Heslo);
        
        return res ? RedirectToAction("Index") : RedirectToAction("Login");
    }
    
    [HttpGet]
    [Route("logout")]
    public IActionResult Logout()
    {
        _userManager.Logout(HttpContext);
        
        return RedirectToAction("Index");
    }

    [Route("error")]
    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing)
        {
            _unitOfWork.Dispose();
        }

        base.Dispose(disposing);
    }
}