using app.Models;
using app.Models.Sprava;
using app.Repositories;
using app.Utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OsobaModel = app.Models.Sprava.OsobaModel;
using TerminModel = app.Models.Sprava.TerminModel;

namespace app.Controllers;

[Route("zajezdy")]
public class ZajezdyController : Controller
{
    private const int PolozekNaStranku = Constants.ResultPerPage;
    
    private readonly IIdConverter _converter;
    private readonly PojisteniRepository _pojisteniRepository;
    private readonly PokojRepository _pokojRepository;
    private readonly DopravaRepository _dopravaRepository;
    private readonly StravaRepository _stravaRepository;
    private readonly StatRepository _statRepository;
    private readonly ObjednavkaRepository _objednavkaRepository;
    private readonly ZajezdRepository _zajezdRepository;

    public ZajezdyController(IIdConverter converter, ZajezdRepository zajezdRepository,
        PojisteniRepository pojisteniRepository, PokojRepository pokojRepository, DopravaRepository dopravaRepository,
        StravaRepository stravaRepository, StatRepository statRepository, ObjednavkaRepository objednavkaRepository)
    {
        _converter = converter;
        _zajezdRepository = zajezdRepository;
        _pojisteniRepository = pojisteniRepository;
        _pokojRepository = pokojRepository;
        _dopravaRepository = dopravaRepository;
        _stravaRepository = stravaRepository;
        _statRepository = statRepository;
        _objednavkaRepository = objednavkaRepository;
    }
    
    private int PocetStran(int pocetRadku, int polozekNaStranku = 0)
    {
        if (polozekNaStranku == 0)
            polozekNaStranku = PolozekNaStranku;

        return (int)Math.Ceiling((double)pocetRadku / polozekNaStranku);
    }

    [Route("")]
    public IActionResult Zajezdy(
        DateOnly datumOd = default,
        DateOnly datumDo = default,
        string? stat = null,
        string? doprava = null,
        string? strava = null,
        int strana = 1
    )
    {
        if (datumOd < DateOnly.FromDateTime(DateTime.Today))
            datumOd = DateOnly.FromDateTime(DateTime.Today);
        if (datumDo == default)
            datumDo = DateOnly.MaxValue;
        if (strana < 1)
            strana = 1;

        int? statId = stat == null ? null : _converter.Decode(stat);
        int? dopravaId = doprava == null ? null : _converter.Decode(doprava);
        int? stravaId = strava == null ? null : _converter.Decode(strava);

        var start = (strana - 1) * PolozekNaStranku;
        var zajezdy = _zajezdRepository.GetZajezdyVTerminu(out var celkovyPocetRadku, datumOd, datumDo, statId,
            dopravaId, stravaId, start, PolozekNaStranku);

        ViewBag.Staty = _statRepository.GetAll(out _, pocetRadku: int.MaxValue).Prepend(new StatModel
        {
            StatId = null,
            Zkratka = "",
            Nazev = ""
        });
        ViewBag.Dopravy = _dopravaRepository.GetAll().Prepend(new DopravaModel
        {
            DopravaId = null,
            Nazev = ""
        });
        ViewBag.Stravy = _stravaRepository.GetAll().Prepend(new StravaModel
        {
            StravaId = null,
            Nazev = ""
        });

        ViewBag.Strana = strana;
        ViewBag.MaxStrana = PocetStran(celkovyPocetRadku);

        return View(zajezdy);
    }

    [Route("{id}")]
    public IActionResult ById(string id)
    {
        var model = _zajezdRepository.Get(_converter.Decode(id));
        ViewBag.Terminy = model.Terminy ?? Array.Empty<TerminModel>();
        ViewBag.Pojisteni = _pojisteniRepository.GetAll();
        ViewBag.Doprava = model.Doprava.Nazev;
        ViewBag.Strava = model.Strava.Nazev;

        if (model.Ubytovani.ObrazkyUbytovani.Length == 0)
            model.Ubytovani.ObrazkyUbytovani = new[]
            {
                new ObrazkyUbytovaniModel
                {
                    ObrazkyUbytovaniId = "0"
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
        ViewBag.Termin = _zajezdRepository.GetTermin(_converter.Decode(termin));
        ViewBag.Pojisteni = _pojisteniRepository.Get(_converter.Decode(pojisteni));
        ViewBag.Pokoj = _pokojRepository.Get(_converter.Decode(pokoj));
        ViewBag.CelkovaCena = _objednavkaRepository.SpocitejCastkuObjednavky(_converter.Decode(pojisteni), _converter.Decode(termin), pocetOsob);

        var osoby = new OsobaModel[pocetOsob - 1];
        for (var i = 0; i < osoby.Length; i++)
            osoby[i] = new OsobaModel
            {
                Jmeno = "",
                Prijmeni = "",
                DatumNarozeni = default
            };
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