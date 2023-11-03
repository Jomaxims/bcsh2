using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace app.Controllers;

[Route("profil")]
public class ProfilController : Controller
{
    [Authorize(Policy = "Zakaznik")]
    [Route("")]
    public IActionResult Profil()
    {
        return View();
    }
}