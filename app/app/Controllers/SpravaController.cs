using app.Managers;
using app.Models.Sprava;
using app.Repositories;
using app.Utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace app.Controllers;

[Authorize(Roles = "Zamestnanec, Admin")]
[Route("sprava")]
public class SpravaController : Controller
{
    private const int PolozekNaStranku = Constants.ResultPerPage;
    private readonly IIdConverter _converter;
    private readonly DopravaRepository _dopravaRepository;

    private readonly ILogger<HomeController> _logger;
    private readonly ObjednavkaRepository _objednavkaRepository;
    private readonly ObrazekUbytovaniRepository _obrazekUbytovaniRepository;
    private readonly PojisteniRepository _pojisteniRepository;
    private readonly PokojRepository _pokojRepository;
    private readonly RoleRepository _roleRepository;
    private readonly StatRepository _statRepository;
    private readonly StravaRepository _stravaRepository;

    private readonly IDictionary<string, string> _typyPolozek = new SortedDictionary<string, string>();
    private readonly IDictionary<string, string> _typyPolozekAdmin = new SortedDictionary<string, string>();
    private readonly UbytovaniRepository _ubytovaniRepository;
    private readonly ZajezdRepository _zajezdRepository;
    private readonly ZakaznikRepository _zakaznikRepository;
    private readonly ZamestnanecRepository _zamestnanecRepository;

    public SpravaController(ILogger<HomeController> logger, IIdConverter converter,
        ZamestnanecRepository zamestnanecRepository,
        StatRepository statRepository, PojisteniRepository pojisteniRepository, DopravaRepository dopravaRepository,
        PokojRepository pokojRepository, StravaRepository stravaRepository, RoleRepository roleRepository,
        ZakaznikRepository zakaznikRepository, UbytovaniRepository ubytovaniRepository,
        ObrazekUbytovaniRepository obrazekUbytovaniRepository, ObjednavkaRepository objednavkaRepository,
        ZajezdRepository zajezdRepository)
    {
        _logger = logger;
        _converter = converter;
        _zamestnanecRepository = zamestnanecRepository;
        _statRepository = statRepository;
        _pojisteniRepository = pojisteniRepository;
        _dopravaRepository = dopravaRepository;
        _pokojRepository = pokojRepository;
        _stravaRepository = stravaRepository;
        _roleRepository = roleRepository;
        _zakaznikRepository = zakaznikRepository;
        _ubytovaniRepository = ubytovaniRepository;
        _obrazekUbytovaniRepository = obrazekUbytovaniRepository;
        _objednavkaRepository = objednavkaRepository;
        _zajezdRepository = zajezdRepository;

        _typyPolozek.Add("Stát", "stat");
        _typyPolozek.Add("Ubytování", "ubytovani");
        _typyPolozek.Add("Pojištění", "pojisteni");
        _typyPolozek.Add("Doprava", "doprava");
        _typyPolozek.Add("Strava", "strava");
        _typyPolozek.Add("Pokoj", "pokoj");
        _typyPolozek.Add("Zájezd", "zajezd");

        _typyPolozekAdmin.Add("Zaměstnanec", "zamestnanec");
        _typyPolozekAdmin.Add("Zákazník", "zakaznik");
        _typyPolozekAdmin.Add("Objednávka", "objednavka");
    }

    private int PocetStran(int pocetRadku, int polozekNaStranku = 0)
    {
        if (polozekNaStranku == 0)
            polozekNaStranku = PolozekNaStranku;

        return (int)Math.Ceiling((double)pocetRadku / polozekNaStranku);
    }

    [Route("chyba")]
    public IActionResult Chyba(string refUrl, IEnumerable<string> chyby)
    {
        return View(new { refUrl, chyby });
    }

    [Route("")]
    public IActionResult Polozky()
    {
        if (User.IsInRole(Role.Admin))
            return View(_typyPolozek.Union(_typyPolozekAdmin).ToDictionary(k => k.Key, v => v.Value));

        return View(_typyPolozek);
    }

    [HttpPost]
    [Route("{typPolozky}/{id}/delete")]
    public IActionResult PolozkyDelete(string typPolozky, string id)
    {
        var actualId = _converter.Decode(id);

        switch (typPolozky)
        {
            case "stat":
                _statRepository.Delete(actualId);
                break;
            case "ubytovani":
                _ubytovaniRepository.Delete(actualId);
                break;
            case "pojisteni":
                _pojisteniRepository.Delete(actualId);
                break;
            case "doprava":
                _dopravaRepository.Delete(actualId);
                break;
            case "strava":
                _stravaRepository.Delete(actualId);
                break;
            case "pokoj":
                _pokojRepository.Delete(actualId);
                break;
            case "zajezd":
                _zajezdRepository.Delete(actualId);
                break;
            case "zamestnanec":
                _zamestnanecRepository.Delete(actualId);
                break;
            case "zakaznik":
                _zakaznikRepository.Delete(actualId);
                break;
            case "objednavka":
                _objednavkaRepository.Delete(actualId);
                break;
            default:
                throw new DatabaseException("Typ položky neexistuje");
        }

        return new RedirectResult($"~/sprava/{typPolozky}");
    }

    // Zákazník
    [Authorize(Roles = "Admin")]
    [HttpGet]
    [Route("zakaznik")]
    public IActionResult Zakaznik(
        string celeJmeno = "",
        string prihlasovaciJmeno = "",
        string email = "",
        string telefon = "",
        string adresa = "",
        int strana = 1
    )
    {
        if (strana < 1)
            strana = 1;

        var start = (strana - 1) * PolozekNaStranku;
        var model = _zakaznikRepository.GetSpravaPreview(out var celkovyPocetRadku, celeJmeno, prihlasovaciJmeno, email,
            telefon, adresa, start, PolozekNaStranku);

        ViewBag.Strana = strana;
        ViewBag.MaxStrana = PocetStran(celkovyPocetRadku);

        return View(model);
    }

    [Authorize(Roles = "Admin")]
    [HttpGet]
    [Route("zakaznik/{id}")]
    public IActionResult ZakaznikEdit(string id)
    {
        if (id == "0") return View(null);

        var model = _zakaznikRepository.Get(_converter.Decode(id));

        return View(model);
    }

    [Authorize(Roles = "Admin")]
    [HttpPost]
    [Route("zakaznik")]
    public IActionResult ZakaznikPost([FromForm] ZakaznikModel model)
    {
        var result = _zakaznikRepository.AddOrEdit(model);

        if (result != 0)
            return RedirectToAction("ZakaznikEdit", new { id = _converter.Encode(result) });

        return RedirectToAction("ZakaznikEdit", new { id = model.ZakaznikId });
    }

    // Stát
    [HttpGet]
    [Route("stat")]
    public IActionResult Stat(string zkratka = "", string nazev = "", int strana = 1)
    {
        if (strana < 1)
            strana = 1;

        var start = (strana - 1) * PolozekNaStranku;
        var model = _statRepository.GetAll(out var celkovyPocetRadku, zkratka, nazev, start, PolozekNaStranku);

        ViewBag.Strana = strana;
        ViewBag.MaxStrana = PocetStran(celkovyPocetRadku);

        return View(model);
    }

    [HttpGet]
    [Route("stat/{id}")]
    public IActionResult StatEdit(string id)
    {
        if (id == "0") return View(null);

        var model = _statRepository.Get(_converter.Decode(id));

        return View(model);
    }

    [HttpPost]
    [Route("stat")]
    public IActionResult StatPost([FromForm] StatModel model)
    {
        var result = _statRepository.AddOrEdit(model);

        if (result != 0)
            return RedirectToAction("StatEdit", new { id = _converter.Encode(result) });

        return RedirectToAction("StatEdit", new { id = model.StatId });
    }

    // Pojištění
    [HttpGet]
    [Route("pojisteni")]
    public IActionResult Pojisteni()
    {
        var model = _pojisteniRepository.GetAll();

        return View(model);
    }

    [HttpGet]
    [Route("pojisteni/{id}")]
    public IActionResult PojisteniEdit(string id)
    {
        if (id == "0") return View(null);

        var model = _pojisteniRepository.Get(_converter.Decode(id));

        return View(model);
    }

    [HttpPost]
    [Route("pojisteni")]
    public IActionResult PojisteniPost([FromForm] PojisteniModel model)
    {
        var result = _pojisteniRepository.AddOrEdit(model);

        if (result != 0)
            return RedirectToAction("PojisteniEdit", new { id = _converter.Encode(result) });

        return RedirectToAction("PojisteniEdit", new { id = model.PojisteniId });
    }

    // Doprava
    [HttpGet]
    [Route("doprava")]
    public IActionResult Doprava()
    {
        var model = _dopravaRepository.GetAll();

        return View(model);
    }

    [HttpGet]
    [Route("doprava/{id}")]
    public IActionResult DopravaEdit(string id)
    {
        if (id == "0") return View(null);

        var model = _dopravaRepository.Get(_converter.Decode(id));

        return View(model);
    }

    [HttpPost]
    [Route("doprava")]
    public IActionResult DopravaPost([FromForm] DopravaModel model)
    {
        var result = _dopravaRepository.AddOrEdit(model);

        if (result != 0)
            return RedirectToAction("DopravaEdit", new { id = _converter.Encode(result) });

        return RedirectToAction("DopravaEdit", new { id = model.DopravaId });
    }

    // Pokoj
    [HttpGet]
    [Route("pokoj")]
    public IActionResult Pokoj()
    {
        var model = _pokojRepository.GetAll();

        return View(model);
    }

    [HttpGet]
    [Route("pokoj/{id}")]
    public IActionResult PokojEdit(string id)
    {
        if (id == "0") return View(null);

        var model = _pokojRepository.Get(_converter.Decode(id));

        return View(model);
    }

    [HttpPost]
    [Route("pokoj")]
    public IActionResult PokojPost([FromForm] PokojModel model)
    {
        var result = _pokojRepository.AddOrEdit(model);

        if (result != 0)
            return RedirectToAction("PokojEdit", new { id = _converter.Encode(result) });

        return RedirectToAction("PokojEdit", new { id = model.PokojId });
    }

    // Strava
    [HttpGet]
    [Route("strava")]
    public IActionResult Strava()
    {
        var model = _stravaRepository.GetAll();

        return View(model);
    }

    [HttpGet]
    [Route("strava/{id}")]
    public IActionResult StravaEdit(string id)
    {
        if (id == "0") return View(null);

        var model = _stravaRepository.Get(_converter.Decode(id));

        return View(model);
    }

    [HttpPost]
    [Route("strava")]
    public IActionResult StravaPost([FromForm] StravaModel model)
    {
        var result = _stravaRepository.AddOrEdit(model);

        if (result != 0)
            return RedirectToAction("StravaEdit", new { id = _converter.Encode(result) });

        return RedirectToAction("StravaEdit", new { id = model.StravaId });
    }

    // Ubytování
    [HttpGet]
    [Route("ubytovani")]
    public IActionResult Ubytovani(
        string nazev = "",
        int? pocetHvezd = null,
        string adresa = "",
        int strana = 1
    )
    {
        if (strana < 1)
            strana = 1;

        var start = (strana - 1) * PolozekNaStranku;
        var model = _ubytovaniRepository.GetSpravaPreview(out var celkovyPocetRadku, nazev, pocetHvezd, adresa, start,
            PolozekNaStranku);

        ViewBag.Strana = strana;
        ViewBag.MaxStrana = PocetStran(celkovyPocetRadku);

        return View(model);
    }

    [HttpGet]
    [Route("ubytovani/{id}")]
    public IActionResult UbytovaniEdit(string id)
    {
        ViewBag.Staty = _statRepository.GetAll(out _, pocetRadku: int.MaxValue);

        if (id == "0") return View(null);

        var model = _ubytovaniRepository.Get(_converter.Decode(id));

        return View(model);
    }

    [HttpPost]
    [Route("ubytovani")]
    public IActionResult UbytovaniPost([FromForm] UbytovaniModel model)
    {
        var newPhotos = new List<ObrazkyUbytovaniModel>();
        var idsToDelete = model.ObrazkyUbytovani?.Select(ou => _converter.Decode(ou.ObrazkyUbytovaniId));
        using var ms = new MemoryStream();

        foreach (var file in Request.Form.Files)
        {
            file.CopyTo(ms);
            newPhotos.Add(new ObrazkyUbytovaniModel
            {
                ObrazkyUbytovaniId = null,
                Nazev = file.FileName,
                Obrazek = ms.ToArray()
            });
        }

        model.ObrazkyUbytovani = newPhotos.ToArray();

        var result = _ubytovaniRepository.AddOrEdit(model);

        if (idsToDelete != null)
            foreach (var id in idsToDelete)
                _obrazekUbytovaniRepository.Delete(id);

        return RedirectToAction("UbytovaniEdit", new { id = _converter.Encode(result) });
    }

    // Zájezd
    [HttpGet]
    [Route("zajezd")]
    public IActionResult Zajezd(
        string ubytovani = "",
        string adresa = "",
        int? cenaOd = null,
        int? cenaDo = null,
        int? slevaOd = null,
        int? slevaDo = null,
        string doprava = "",
        string strava = "",
        int strana = 1
    )
    {
        if (strana < 1)
            strana = 1;

        int? dopravaId = doprava == "" ? null : _converter.Decode(doprava);
        int? stravaId = strava == "" ? null : _converter.Decode(strava);

        var start = (strana - 1) * PolozekNaStranku;
        var model = _zajezdRepository.GetSpravaPreview(out var celkovyPocetRadku, ubytovani, adresa, cenaOd, cenaDo,
            slevaOd, slevaDo, dopravaId, stravaId, start, PolozekNaStranku);

        ViewBag.Strana = strana;
        ViewBag.MaxStrana = PocetStran(celkovyPocetRadku);

        ViewBag.Stravy = _stravaRepository.GetAll().Prepend(new StravaModel
        {
            StravaId = "",
            Nazev = ""
        });
        ViewBag.Dopravy = _dopravaRepository.GetAll().Prepend(new DopravaModel
        {
            DopravaId = "",
            Nazev = ""
        });

        return View(model);
    }

    [HttpGet]
    [Route("zajezd/{id}")]
    public IActionResult ZajezdEdit(string id)
    {
        ViewBag.Ubytovani = _ubytovaniRepository.GetSpravaPreview(out _, pocetRadku: int.MaxValue).ToArray();
        ViewBag.Pokoje = _pokojRepository.GetAll();
        ViewBag.Stravy = _stravaRepository.GetAll();
        ViewBag.Dopravy = _dopravaRepository.GetAll();

        if (id == "0") return View(null);

        var model = _zajezdRepository.Get(_converter.Decode(id));

        return View(model);
    }

    [HttpPost]
    [Route("zajezd")]
    public IActionResult ZajezdPost([FromForm] ZajezdModel model)
    {
        var chyby = new List<string>();

        foreach (var termin in model.Terminy ?? Array.Empty<TerminModel>())
        {
            if (termin.Od > termin.Do)
                chyby.Add(
                    $"Termín od {termin.Od.ToString("o")} musí být menší než termín do {termin.Od.ToString("o")}.");

            foreach (var pokojTerminu in termin.PokojeTerminu ?? Array.Empty<PokojTerminu>())
                if (pokojTerminu.PocetObsazenychPokoju > pokojTerminu.CelkovyPocetPokoju)
                    chyby.Add(
                        $"Počet obsazených pokojů {pokojTerminu.PocetObsazenychPokoju} musí být menší než počet celkových pokojů {pokojTerminu.CelkovyPocetPokoju}.");
        }

        if (chyby.Count > 0)
            return RedirectToAction("Chyba", new { refUrl = $"/sprava/zajezd/{model.ZajezdId ?? "0"}", chyby });

        var result = _zajezdRepository.AddOrEdit(model);

        return RedirectToAction("ZajezdEdit", new { id = _converter.Encode(result) });
    }

    // Objednávka
    [Authorize(Roles = "Admin")]
    [HttpGet]
    [Route("objednavka")]
    public IActionResult Objednavka(
        DateOnly datumOd = default,
        DateOnly datumDo = default,
        string zakaznik = "",
        string ubytovani = "",
        bool? zaplaceno = null,
        int? cenaOd = null,
        int? cenaDo = null,
        int strana = 1
    )
    {
        if (strana < 1)
            strana = 1;

        if (datumOd == default)
            datumOd = DateOnly.FromDateTime(DateTime.Today);

        var start = (strana - 1) * PolozekNaStranku;
        var model = _objednavkaRepository.GetSpravaPreview(out var celkovyPocetRadku, zakaznik, datumOd, datumDo,
            ubytovani, cenaOd, cenaDo, zaplaceno, start, PolozekNaStranku);

        ViewBag.Strana = strana;
        ViewBag.MaxStrana = PocetStran(celkovyPocetRadku);

        return View(model);
    }

    [Authorize(Roles = "Admin")]
    [HttpGet]
    [Route("objednavka/{id}")]
    public IActionResult ObjednavkaEdit(string id)
    {
        var zajezd = _zajezdRepository.Get(3);
        ViewBag.Terminy = zajezd.Terminy ?? Array.Empty<TerminModel>();
        ViewBag.Pojisteni = _pojisteniRepository.GetAll();

        var model = _objednavkaRepository.Get(_converter.Decode(id));

        return View(model);
    }

    [Authorize(Roles = "Admin")]
    [HttpPost]
    [Route("objednavka")]
    public IActionResult ObjednavkaPost([FromForm] ObjednavkaModel model)
    {
        var result = _objednavkaRepository.AddOrEdit(model);

        return RedirectToAction("ObjednavkaEdit", new { id = _converter.Encode(result) });
    }

    // Zaměstnanec
    [Authorize(Roles = "Admin")]
    [HttpGet]
    [Route("zamestnanec")]
    public IActionResult Zamestnanec(
        string celeJmeno = "",
        string prihlasovaciJmeno = "",
        string role = "",
        string nadrizeny = "",
        int strana = 1
    )
    {
        if (strana < 1)
            strana = 1;

        ViewBag.Role = _roleRepository.GetAll();

        var start = (strana - 1) * PolozekNaStranku;
        var roleId = role == "" ? 0 : _converter.Decode(role);
        var model = _zamestnanecRepository.GetSpravaPreview(out var celkovyPocetRadku, celeJmeno, prihlasovaciJmeno,
            roleId, nadrizeny, start, PolozekNaStranku);

        ViewBag.Strana = strana;
        ViewBag.MaxStrana = PocetStran(celkovyPocetRadku);

        return View(model);
    }

    [Authorize(Roles = "Admin")]
    [HttpGet]
    [Route("zamestnanec/{id}")]
    public IActionResult ZamestnanecEdit(string id)
    {
        var nikdo = new ZamestnanecModel();
        ViewBag.Role = _roleRepository.GetAll().Reverse();

        if (id == "0")
        {
            ViewBag.Zamestnanci = _zamestnanecRepository.GetMozniNadrizeni(0).Prepend(nikdo);

            return View(null);
        }

        ViewBag.Zamestnanci = _zamestnanecRepository.GetMozniNadrizeni(_converter.Decode(id)).Prepend(nikdo);
        var model = _zamestnanecRepository.Get(_converter.Decode(id));

        return View(model);
    }

    [Authorize(Roles = "Admin")]
    [HttpPost]
    [Route("zamestnanec")]
    public IActionResult ZamestnanecPost([FromForm] ZamestnanecModel model)
    {
        var result = _zamestnanecRepository.AddOrEdit(model);

        if (result != 0)
            return RedirectToAction("ZamestnanecEdit", new { id = _converter.Encode(result) });

        return RedirectToAction("ZamestnanecEdit", new { id = model.ZamestnanecId });
    }
}