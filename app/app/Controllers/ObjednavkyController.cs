using app.Models;
using app.Utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace app.Controllers;

[Authorize(Policy = "Zakaznik")]
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

        ViewBag.ZajezdId = _converter.Encode(1);
        ViewBag.CelkovaCena = 13896;
        var osoby = new OsobaModel[3 - 1];
        for (var i = 0; i < osoby.Length; i++)
        {
            osoby[i] = new OsobaModel
            {
                Jmeno = $"Jmeno {i}",
                Prijmeni = $"Prijmeni {i}",
                DatumNarozeni = default
            };

        }

        var model = new ObjednavkaModel()
        {
            ObjednavkaId = "jyhxc",
            Zaplacena = false,
            Zajezd = new ZajezdNakupModel
            {
                Termin = "10.12.2023 - 15.12.2023",
                PocetOsob = 3,
                Pojisteni = "Klasik",
                Pokoj = "Dvoulůžko"
            },
            Osoby = osoby
        };
        
        return View(model);
    }
    
    [HttpPost]
    [Route("")]
    public IActionResult ObjednavkaPost([FromForm] NakupModel nakup)
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
        
        // TODO platba (nastavit objednávku jako zaplacena)
        
        return RedirectToAction("ById", routeValues: new { id });
    }
    
    [HttpPost]
    [Route("{id}/smazat")]
    public IActionResult ObjednavkaDelete(string id)
    {
        var objednavkaId = _converter.Decode(id);
        
        return RedirectToAction("Profil", "Profil");
    }
}