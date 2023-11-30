using System.Dynamic;
using app.Models;
using app.Models.Sprava;
using app.Repositories;
using app.Utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OsobaModel = app.Models.OsobaModel;
using PojisteniModel = app.Models.PojisteniModel;
using PokojModel = app.Models.PokojModel;
using TerminModel = app.Models.TerminModel;
using UbytovaniModel = app.Models.UbytovaniModel;
using ZajezdModel = app.Models.ZajezdModel;

namespace app.Controllers;

[Route("zajezdy")]
public class ZajezdyController : Controller
{
    private readonly IIdConverter _converter;
    private readonly ZajezdRepository _zajezdRepository;
    private readonly PojisteniRepository _pojisteniRepository;
    private readonly PokojRepository _pokojRepository;

    public ZajezdyController(IIdConverter converter, ZajezdRepository zajezdRepository, PojisteniRepository pojisteniRepository, PokojRepository pokojRepository)
    {
        _converter = converter;
        _zajezdRepository = zajezdRepository;
        _pojisteniRepository = pojisteniRepository;
        _pokojRepository = pokojRepository;
    }

    [Route("")]
    public IActionResult Zajezdy(
        DateOnly datumOd = default,
        DateOnly datumDo = default,
        string zeme = "",
        string doprava = "",
        string strava = "",
        int strana = 1
        )
    {
        var maxStrana = 3;
        
        if (datumOd < DateOnly.FromDateTime(DateTime.Today))
            datumOd = DateOnly.FromDateTime(DateTime.Today);
        if (datumDo == default)
            datumDo = DateOnly.MaxValue;
        if (strana < 1 || strana > maxStrana)
            strana = 1;
        
        var zajezdy = new List<ZajezdNahledModel>();

        for (var i = 1; i <= 5; i++)
        {
            zajezdy.Add(new ZajezdNahledModel
            {
                Id = _converter.Encode(i),
                Nazev = $"El Pinar Hotel {i}",
                PocetHvezd = 5,
                Lokalita = "Španělsko - Ibiza - San Antonio",
                ZkracenyPopis =
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at ante lobortis, ultrices ligula ac, congue dolor. Cras malesuada venenatis nunc, ac sagittis elit pellentesque ut. Phasellus id maximus eros. In ac posuere nibh, ac dignissim risus. Ut ut libero elit. Proin at aliquam nisl, et mollis odio. Integer gravida ante dolor, nec vulputate elit interdum vitae. Etiam nisi lacus, volutpat eu mi quis, iaculis dapibus arcu.",
                Doprava = "Letecky",
                Strava = "All Inclusive",
                CenaZaOsobu = 8569,
                CenaPredSlevou = 10681,
                FotoId = _converter.Encode(i),
                Od = "11.12.2023",
                Do = "15.17.2023"
            });
        }

        ViewBag.Staty = new[]
        {
            new StatModel
            {
                StatId = "ykux",
                Nazev = "ČR"
            },
            new StatModel
            {
                StatId = "fhg",
                Nazev = "Slovensko"
            },
            new StatModel
            {
                StatId = "bnm",
                Nazev = "Albánie"
            }
        };
        ViewBag.Dopravy = new[]
        {
            new DopravaModel
            {
                DopravaId = "yjc",
                Nazev = "Bez dopravy"
            },
            new DopravaModel
            {
                DopravaId = "asedqw",
                Nazev = "Letecky"
            },
            new DopravaModel
            {
                DopravaId = "324",
                Nazev = "Autobus"
            }
        };
        ViewBag.Stravy = new[]
        {
            new StravaModel
            {
                StravaId = "xuctgv",
                Nazev = "Polopenze"
            },
            new StravaModel
            {
            StravaId = "yxcvb",
            Nazev = "Plná penze"
            },
            new StravaModel
            {
                StravaId = "rtez",
                Nazev = "Bez stravy"
            }
        };

        ViewBag.Strana = strana;
        ViewBag.MaxStrana = maxStrana;
        
        return View(zajezdy);
    }
    
    [Route("{id}")]
    public IActionResult ById(string id)
    {
        var model = _zajezdRepository.Get(_converter.Decode(id));
        ViewBag.Terminy = model.Terminy ?? Array.Empty<app.Models.Sprava.TerminModel>();
        ViewBag.Pojisteni = _pojisteniRepository.GetAll();
        ViewBag.Doprava = model.Doprava.Nazev;
        ViewBag.Strava = model.Strava.Nazev;

        if (model.Ubytovani.ObrazkyUbytovani.Length == 0)
        {
            model.Ubytovani.ObrazkyUbytovani = new[]
            {
                new ObrazkyUbytovaniModel
                {
                    ObrazkyUbytovaniId = "0",
                }
            };
        }

        return View(model);
    }
    
    [Authorize(Policy = "Zakaznik")]
    [HttpPost]
    [Route("{id}/nakup")]
    public IActionResult NakupPost([FromRoute] string id, [FromForm] ZajezdNakupModel model)
    {
        if (!ModelState.IsValid)
            return RedirectToAction("ById", new { id });
        
        var parameters = new { id, model.Termin, model.PocetOsob, model.Pojisteni, model.Pokoj };
        return RedirectToAction("Nakup", "Zajezdy", parameters);
    }
    
    [Authorize(Policy = "Zakaznik")]
    [HttpGet]
    [Route("{id}/nakup")]
    public IActionResult Nakup(string id, string termin, int pocetOsob, string pojisteni, string pokoj)
    {
        ViewBag.Termin = _zajezdRepository.GetTermin(_converter.Decode(termin));
        ViewBag.Pojisteni = _pojisteniRepository.Get(_converter.Decode(pojisteni));
        ViewBag.Pokoj = _pokojRepository.Get(_converter.Decode(pokoj));
        ViewBag.CelkovaCena = 13896;

        var osoby = new Models.Sprava.OsobaModel[pocetOsob-1];
        for (var i = 0; i < osoby.Length; i++)
        {
            osoby[i] = new Models.Sprava.OsobaModel
            {
                Jmeno = "",
                Prijmeni = "",
                DatumNarozeni = default
            };

        }
        var model = new NakupModel
        {
            Zajezd = new ZajezdNakupModel
            {
                Termin = termin,
                PocetOsob = pocetOsob,
                Pojisteni = pojisteni,
                Pokoj = pokoj
            },
            Osoby = osoby
        };

        return View(model);
    }
}