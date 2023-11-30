using System.Security.Claims;
using app.Models;
using app.Models.Sprava;
using app.Repositories;
using app.Utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ObjednavkaModel = app.Models.Sprava.ObjednavkaModel;
using PojisteniModel = app.Models.Sprava.PojisteniModel;
using PokojModel = app.Models.Sprava.PokojModel;
using TerminModel = app.Models.Sprava.TerminModel;

namespace app.Controllers;

[Authorize(Policy = "Zakaznik")]
[Route("objednavky")]
public class ObjednavkyController : Controller
{
    private readonly IIdConverter _converter;
    private readonly ObjednavkaRepository _objednavkaRepository;

    public ObjednavkyController(IIdConverter converter, ObjednavkaRepository objednavkaRepository)
    {
        _converter = converter;
        _objednavkaRepository = objednavkaRepository;
    }
    
    [Route("{id}")]
    public IActionResult ById(string id)
    {
        var model = _objednavkaRepository.Get(_converter.Decode(id));
        
        return View(model);
    }
    
    [HttpPost]
    [Route("")]
    public IActionResult ObjednavkaPost([FromForm] NakupModel nakup)
    {
        var zakaznikId = int.Parse(User.Claims.First(claim => claim.Type == ClaimTypes.NameIdentifier).Value);

        var model = new ObjednavkaModel
        {
            PocetOsob = nakup.Zajezd.PocetOsob,
            Osoby = nakup.Osoby,
            Zakaznik = new ZakaznikModel
            {
                ZakaznikId = _converter.Encode(zakaznikId)
            },
            Termin = new TerminModel
            {
                TerminId = nakup.Zajezd.Termin
            },
            Pokoj = new PokojModel
            {
                PokojId = nakup.Zajezd.Pokoj
            },
            Platba = new PlatbaModel
            {
                Castka = 0,
                CisloUctu = null,
                Zaplacena = false
            },
            Pojisteni = new PojisteniModel
            {
                PojisteniId = nakup.Zajezd.Pojisteni
            }
        };

        var result = _objednavkaRepository.AddOrEdit(model);

        return RedirectToAction("ById", routeValues: new { id = _converter.Encode(result) });
    }
    
    [HttpPost]
    [Route("{id}/platba")]
    public IActionResult PlatbaPost(string id, [FromForm] ObjednavkaPlatbaModel model)
    {
        var platbaId = _converter.Decode(model.PlatbaId);
        
        _objednavkaRepository.ZaplatObjednavku(platbaId, model.CisloKarty);
        
        return RedirectToAction("ById", routeValues: new { id });
    }
    
    [HttpPost]
    [Route("{id}/smazat")]
    public IActionResult ObjednavkaDelete(string id)
    {
        _objednavkaRepository.Delete(_converter.Decode(id));
        
        return RedirectToAction("Profil", "Profil");
    }
}