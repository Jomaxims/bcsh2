using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Sqids;

namespace app.Controllers;

[Authorize(Policy = "Zamestnanec")]
[Route("zamestnanec/sprava")]
public class SpravaController : Controller
{
    private readonly SqidsEncoder<int> _encoder;

    public SpravaController(SqidsEncoder<int> encoder)
    {
        _encoder = encoder;
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
        ViewData["id"] = _encoder.Decode(id)[0];
        
        return View();
    }
    
    [HttpPost]
    [Route("{typPolozky}/{id}")]
    public IActionResult EditEntity(string typPolozky, string id)
    {
        var idDecoded = _encoder.Decode(id)[0];
        // TODO edit/add entity

        return Ok();
    }
    
    [HttpDelete]
    [Route("{typPolozky}/{id}")]
    public IActionResult DeleteEntity(string typPolozky, string id)
    {
        var idDecoded = _encoder.Decode(id)[0];
        // TODO remove entity
        
        return Ok();
    }
}