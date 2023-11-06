using app.Utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace app.Controllers;

[Authorize(Roles = "Admin")]
[Route("admin")]
public class AdminController : Controller
{
    private readonly IIdConverter _converter;

    public AdminController(IIdConverter converter)
    {
        _converter = converter;
    }
    
    [Route("panel")]
    public IActionResult Panel()
    {
        return View();
    }
    
    [Route("logy/{typLogu}")]
    public IActionResult Logy(string typLogu)
    {
        ViewData["typLogu"] = typLogu;
        
        return View();
    }
    
    [Route("uzivatele")]
    public IActionResult Uzivatele()
    {
        return View();
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