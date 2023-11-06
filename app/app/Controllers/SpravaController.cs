using app.Managers;
using app.Utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Sqids;

namespace app.Controllers;

[Authorize(Roles = "Zamestnanec, Admin")]
[Route("sprava")]
public class SpravaController : Controller
{
    private readonly IIdConverter _converter;

    public SpravaController(IIdConverter converter)
    {
        _converter = converter;
    }
    
    [Route("")]
    public IActionResult Polozky()
    {
        var defaultTyp = "a";
        
        return RedirectToAction("Polozky", routeValues: new { typPolozky = defaultTyp });
    }
    
    [Route("{typPolozky}")]
    public IActionResult Polozky(string typPolozky)
    {
        ViewData["typPolozky"] = typPolozky;
        
        return View();
    }
    
    [HttpGet]
    [Route("{typPolozky}/{id}")]
    public IActionResult PolozkyEdit(string typPolozky, string id)
    {
        ViewData["typPolozky"] = typPolozky;
        ViewData["id"] = _converter.Decode(id);
        
        return View();
    }
    
    [HttpPost]
    [Route("{typPolozky}/{id}")]
    public IActionResult PolozkyEditPost(string typPolozky, string id)
    {
        var idDecoded = _converter.Decode(id);
        // TODO edit/add entity

        return Ok();
    }
    
    [HttpDelete]
    [Route("{typPolozky}/{id}")]
    public IActionResult PolozkyDelete(string typPolozky, string id)
    {
        var idDecoded = _converter.Decode(id);
        // TODO remove entity
        
        return Ok();
    }
}