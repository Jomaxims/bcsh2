using app.DAL;
using app.Managers;
using app.Models;
using app.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace app.Controllers;

public class HomeController : Controller
{
    private readonly ILogger<HomeController> _logger;
    private readonly IDbUnitOfWork _unitOfWork;

    public HomeController(ILogger<HomeController> logger, IDbUnitOfWork unitOfWork)
    {
        _logger = logger;
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
        return View(new ErrorViewModel { Message = chyba });
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing) _unitOfWork.Dispose();

        base.Dispose(disposing);
    }
}