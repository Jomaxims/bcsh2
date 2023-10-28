using app.Managers;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Sqids;

namespace app.Controllers;

[Authorize(Roles = "Admin")]
[Route("admin")]
public class AdminController : Controller
{
    private readonly SqidsEncoder<int> _encoder;

    public AdminController(SqidsEncoder<int> encoder)
    {
        _encoder = encoder;
    }
    
    [Route("logy/{typLogu}")]
    public IActionResult Logy(string typLogu)
    {
        ViewData["typLogu"] = typLogu;
        
        return View();
    }
    
    [Route("prepnout")]
    public IActionResult Prepnout()
    {
        return View();
    }
    
    [Route("uzivatele")]
    public IActionResult Uzivatele()
    {
        return View();
    }
    
    [HttpGet]
    [Route("uzivatele/{id}")]
    public IActionResult UzivateleEdit(string id)
    {
        ViewData["id"] = _encoder.Decode(id)[0];
        
        return View();
    }
    
    [HttpPost]
    [Route("uzivatele/{id}")]
    public IActionResult EditEntity(string id)
    {
        ViewData["id"] = _encoder.Decode(id)[0];
        
        return Ok();
    }
    
    [HttpDelete]
    [Route("uzivatele/{id}")]
    public IActionResult DeleteEntity(string id)
    {
        ViewData["id"] = _encoder.Decode(id)[0];
        
        return Ok();
    }
}