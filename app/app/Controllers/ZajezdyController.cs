using System.Dynamic;
using app.Models;
using app.Models.Sprava;
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

    public ZajezdyController(IIdConverter converter)
    {
        _converter = converter;
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
        ViewData["id"] = _converter.Decode(id);

        var model = new ZajezdModel
        {
            CenaZaOsobu = 5976,
            CenaPredSlevou = 6893,
            Popis = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at ante lobortis, ultrices ligula ac, congue dolor.",
            Doprava = "Letadlo",
            Ubytovani = new UbytovaniModel
            {
                FotoIds = new []{_converter.Encode(1), _converter.Encode(2), _converter.Encode(3)},
                Nazev = "Hotel pepa",
                PocetHvezd = 6,
                Lokalita = "Albánie - Pobřeží",
                Popis = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean at ante lobortis, ultrices ligula ac, congue dolor. Cras malesuada venenatis nunc, ac sagittis elit pellentesque ut. Phasellus id maximus eros. In ac posuere nibh, ac dignissim risus. Ut ut libero elit. Proin at aliquam nisl, et mollis odio. Integer gravida ante dolor, nec vulputate elit interdum vitae. Etiam nisi lacus, volutpat eu mi quis, iaculis dapibus arcu."
            },
            Strava = "Plná penze",
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
        // ViewBag.Termin = _converter.Decode(termin);
        // ViewBag.Pojisteni = _converter.Decode(pojisteni);
        // ViewBag.Pokoj = _converter.Decode(pokoj);
        ViewBag.Termin = "10.12.2023 - 15.12.2023";
        ViewBag.Pojisteni = "Klasik";
        ViewBag.Pokoj = "Dvoulůžko";
        ViewBag.CelkovaCena = 13896;

        var osoby = new OsobaModel[pocetOsob - 1];
        for (var i = 0; i < osoby.Length; i++)
        {
            osoby[i] = new OsobaModel
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