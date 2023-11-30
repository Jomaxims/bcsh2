using System.Diagnostics;
using app.DAL;
using app.Managers;
using Microsoft.AspNetCore.Mvc;
using app.Models;
using app.Models.Sprava;
using app.Repositories;

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
        return View();
    }

    [Route("kontakt")]
    public IActionResult Kontakt()
    {
        throw new DatabaseException();
        return BadRequest();
    }

    [Route("error")]
    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error(string chyba = "")
    {
        return View(new ErrorViewModel { Message = chyba});
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