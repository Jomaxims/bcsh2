using Microsoft.AspNetCore.Mvc;
using Sqids;

namespace app.Controllers;

[Route("zajezdy")]
public class ZajezdyController : Controller
{
    private readonly SqidsEncoder<int> _encoder;

    public ZajezdyController(SqidsEncoder<int> encoder)
    {
        _encoder = encoder;
    }

    [Route("")]
    public IActionResult Zajezdy()
    {
        return View();
    }
    
    [Route("{id}")]
    public IActionResult ById(string id)
    {
        ViewData["id"] = _encoder.Decode(id)[0];
        return View();
    }
    
    [Route("{id}/nakup")]
    public IActionResult Nakup(string id)
    {
        ViewData["id"] = _encoder.Decode(id)[0];
        return View();
    }
}