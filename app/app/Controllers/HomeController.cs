using System.Diagnostics;
using app.DAL;
using app.DAL.Repositories;
using app.Managers;
using Microsoft.AspNetCore.Mvc;
using app.Models;

namespace app.Controllers;

public class HomeController : Controller
{
    private readonly ILogger<HomeController> _logger;
    private readonly UserManager _userManager;
    private readonly IDbUnitOfWork _unitOfWork;

    public HomeController(ILogger<HomeController> logger, UserManager userManager, IDbUnitOfWork unitOfWork)
    {
        _logger = logger;
        _userManager = userManager;
        _unitOfWork = unitOfWork;
    }

    [Route("")]
    public IActionResult Index()
    {
        return View(new { Name = "pepa"});
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
    public IActionResult RegisterPost(RegisterModel? model)
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