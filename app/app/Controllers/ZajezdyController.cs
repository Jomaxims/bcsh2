using System.Dynamic;
using app.Models;
using app.Utils;
using Microsoft.AspNetCore.Mvc;

namespace app.Controllers;

[Route("zajezdy")]
public class ZajezdyController : Controller
{
    private readonly IIdConverter _converter;

    public ZajezdyController(IIdConverter converter)
    {
        _converter = converter;
    }

    [Route("")]
    public IActionResult Zajezdy()
    {
        var zajezdy = new List<ZajezdNahledModel>();

        for (var i = 1; i <= 30; i++)
        {
            zajezdy.Add(new()
            {
                Id = _converter.Encode(i),
                Nazev = "nazev",
                PocetHvezd = 5,
                Lokalita = "lokality",
                ZkracenyPopis = "popis",
                Doprava = "doprava",
                Strava = "strava",
                CenaZaOsobu = 8569,
                CenaPredSlevou = 10681,
                FotoId = _converter.Encode(i)
            });
        }
        
        return View(zajezdy);
    }
    
    [Route("{id}")]
    public IActionResult ById(string id)
    {
        ViewData["id"] = _converter.Decode(id);

        var model = new ZajezdModel
        {
            CenaZaOsobu = 5976,
            Doprava = "Letadlo",
            Ubytovani = new()
            {
                ObrazkyIds = new []{_converter.Encode(1), _converter.Encode(2), _converter.Encode(3)},
                Nazev = "Hotel pepa",
                PocetHvezd = 6,
                Lokalita = "Albánie - Pobřeží",
                Popis = "fajny bober"
            },
            Strava = "Plná",
            Terminy = new []
            {
                new TerminModel
                {
                    Id = _converter.Encode(3),
                    Od = new DateOnly(2021,
                        11,
                        10),
                    Do = new DateOnly(2021,
                        11,
                        15),
                    Pokoje = new []
                    {
                        new PokojModel
                        {
                            Id = _converter.Encode(69),
                            Nazev = "Dvoulůžko",
                            PocetMist = 2,
                        }
                    }
                },
                new TerminModel
                {
                    Id = _converter.Encode(5),
                    Od = new DateOnly(2021,
                        11,
                        15),
                    Do = new DateOnly(2021,
                        11,
                        20),
                    Pokoje = new []
                    {
                        new PokojModel
                        {
                            Id = _converter.Encode(12),
                            Nazev = "Trojlůžko",
                            PocetMist = 3,
                        }
                    }
                }
            },
            Pojisteni = new []
            {
                new PojisteniModel
                {
                    Id = _converter.Encode(1),
                    CenaZaDen = 80,
                    Popis = "Klasik"
                },
                new PojisteniModel
                {
                    Id = _converter.Encode(2),
                    CenaZaDen = 150,
                    Popis = "Extra"
                }
            }
        };

        return View(model);
    }
    
    [HttpPost]
    [Route("{id}/nakup")]
    public IActionResult NakupPost([FromRoute] string id, [FromForm] NakupModel model)
    {
        var parameters = new { id, model.Termin, model.PocetOsob, model.Pojisteni, model.Pokoj };
        return RedirectToAction("Nakup", "Zajezdy", parameters);
    }
    
    [HttpGet]
    [Route("{id}/nakup")]
    public IActionResult Nakup(string id, string termin, string pocetOsob, string pojisteni, string pokoj)
    {
        ViewBag.ZajezdId = _converter.Decode(id);
        ViewBag.TerminId = _converter.Decode(termin);
        ViewBag.PojisteniId = _converter.Decode(pojisteni);
        ViewBag.PokojId = _converter.Decode(pokoj);

        return View();
    }
}