using app.Utils;
using Microsoft.AspNetCore.Mvc;

namespace app.Controllers;

[Route("objednavky")]
public class ObjednavkyController : Controller
{
    private readonly IIdConverter _converter;

    public ObjednavkyController(IIdConverter converter)
    {
        _converter = converter;
    }
    
    [Route("{id}")]
    public IActionResult ById(string id)
    {
        var objednavkaId = _converter.Decode(id);
        
        return View();
    }
    
    [HttpPost]
    [Route("")]
    public IActionResult ObjednavkaPost()
    {
        var id = _converter.Encode(5);
        
        // TODO vytvořit objednávku a vrátit id
        
        return RedirectToAction("ById", routeValues: new { id });
    }
    
    [HttpPost]
    [Route("{id}/platba")]
    public IActionResult PlatbaPost(string id)
    {
        var objednavkaId = _converter.Decode(id);
        
        // TODO platba
        
        return RedirectToAction("ById", routeValues: new { id });
    }
}