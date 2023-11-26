using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Repositories;
using app.Utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Role = app.Managers.Role;

namespace app.Controllers;

[Authorize(Roles = "Zamestnanec, Admin")]
[Route("sprava")]
public class SpravaController : Controller
{
    private const int PolozekNaStranku = Constants.ResultPerPage;

    private readonly ILogger<HomeController> _logger;
    private readonly IIdConverter _converter;
    private readonly ZamestnanecRepository _zamestnanecRepository;
    private readonly StatRepository _statRepository;
    private readonly PojisteniRepository _pojisteniRepository;
    private readonly DopravaRepository _dopravaRepository;
    private readonly PokojRepository _pokojRepository;
    private readonly StravaRepository _stravaRepository;
    private readonly RoleRepository _roleRepository;

    private readonly IDictionary<string, string> _typyPolozek = new SortedDictionary<string, string>();

    public SpravaController(ILogger<HomeController> logger, IIdConverter converter,
        ZamestnanecRepository zamestnanecRepository,
        StatRepository statRepository, PojisteniRepository pojisteniRepository, DopravaRepository dopravaRepository,
        PokojRepository pokojRepository, StravaRepository stravaRepository, RoleRepository roleRepository)
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

        _typyPolozek.Add("Zákazník", "zakaznik");
        _typyPolozek.Add("Stát", "stat");
        _typyPolozek.Add("Ubytování", "ubytovani");
        _typyPolozek.Add("Pojištění", "pojisteni");
        _typyPolozek.Add("Doprava", "doprava");
        _typyPolozek.Add("Strava", "strava");
        _typyPolozek.Add("Pokoj", "pokoj");
        _typyPolozek.Add("Objednávka", "objednavka");
        _typyPolozek.Add("Zájezd", "zajezd");
    }

    private int PocetStran(int pocetRadku, int polozekNaStranku = 0)
    {
        if (polozekNaStranku == 0)
            polozekNaStranku = PolozekNaStranku;

        return (int)Math.Ceiling((double)pocetRadku / polozekNaStranku);
    }

    [Route("")]
    public IActionResult Polozky()
    {
        if (User.IsInRole(Role.Admin))
        {
            _typyPolozek.Add("Zaměstnanec", "zamestnanec");
        }

        return View(_typyPolozek);
    }

    [HttpPost]
    [Route("{typPolozky}/{id}/delete")]
    public IActionResult PolozkyDelete(string typPolozky, string id)
    {
        if (!_typyPolozek.Values.Contains(typPolozky))
            return new RedirectResult($"~/sprava/{typPolozky}");

        var actualId = _converter.Decode(id);

        switch (typPolozky)
        {
            case "stat":
                _statRepository.Delete(actualId);
                break;
            case "pojisteni":
                _pojisteniRepository.Delete(actualId);
                break;
            case "doprava":
                _dopravaRepository.Delete(actualId);
                break;
            case "pokoj":
                _pokojRepository.Delete(actualId);
                break;
            case "strava":
                _stravaRepository.Delete(actualId);
                break;
            case "zamestnanec":
                _zamestnanecRepository.Delete(actualId);
                break;
            default:
                throw new DatabaseException("Typ položky neexistuje");
        }

        return new RedirectResult($"~/sprava/{typPolozky}");
    }

    // Zákazník
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
        var maxStrana = 3;

        if (strana < 1 || strana > maxStrana)
            strana = 1;

        var model = new ZakaznikModel[20];

        for (var i = 0; i < model.Length; i++)
        {
            model[i] = new ZakaznikModel
            {
                ZakaznikId = _converter.Encode(i),
                PrihlasovaciUdaje = new PrihlasovaciUdajeModel
                {
                    PrihlasovaciUdajeId = null,
                    Jmeno = $"pepa123 {i}",
                    Heslo = null
                },
                Osoba = new OsobaModel
                {
                    OsobaId = "oiyx",
                    Jmeno = "Pepa",
                    Prijmeni = "Zdepa",
                    DatumNarozeni = default
                },
                Kontakt = new KontaktModel
                {
                    KontaktId = "oizva",
                    Email = "pepa@zdepa.pp",
                    Telefon = "8973541689"
                },
                Adresa = new AdresaModel
                {
                    AdresaId = "poxaw",
                    Ulice = "Pepa",
                    CisloPopisne = "Zdepa",
                    Mesto = "Pepov",
                    Psc = "97618",
                    Poznamka = null,
                }
            };
        }

        ViewBag.Strana = strana;
        ViewBag.MaxStrana = maxStrana;

        return View(model);
    }

    [HttpGet]
    [Route("zakaznik/{id}")]
    public IActionResult ZakaznikEdit(string id)
    {
        if (id == "0")
        {
            return View(null);
        }

        ZakaznikModel? model = null;

        if (_converter.Decode(id) > 0)
        {
            model = new ZakaznikModel
            {
                ZakaznikId = id,
                PrihlasovaciUdaje = new PrihlasovaciUdajeModel
                {
                    PrihlasovaciUdajeId = null,
                    Jmeno = "pepa123",
                    Heslo = null
                },
                Osoba = new OsobaModel
                {
                    OsobaId = "oiyx",
                    Jmeno = "Pepa",
                    Prijmeni = "Zdepa",
                    DatumNarozeni = new DateOnly(2000, 1, 1)
                },
                Kontakt = new KontaktModel
                {
                    KontaktId = "oizva",
                    Email = "pepa@zdepa.pp",
                    Telefon = "8973541689"
                },
                Adresa = new AdresaModel
                {
                    AdresaId = "poxaw",
                    Ulice = "Pepa",
                    CisloPopisne = "Zdepa",
                    Mesto = "Pepov",
                    Psc = "97618",
                    Poznamka = null,
                }
            };
        }

        return View(model);
    }

    [HttpPost]
    [Route("zakaznik")]
    public IActionResult ZakaznikPost([FromForm] ZakaznikModel model)
    {
        // var idDecoded = _converter.Decode(id);
        // TODO edit/add entity

        return Ok();
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
        if (id == "0")
        {
            return View(null);
        }

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
        if (id == "0")
        {
            return View(null);
        }

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
        if (id == "0")
        {
            return View(null);
        }

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
        if (id == "0")
        {
            return View(null);
        }

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
        if (id == "0")
        {
            return View(null);
        }

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
        string pocetHvezd = "",
        string adresa = "",
        int strana = 1
    )
    {
        var maxStrana = 3;

        if (strana < 1 || strana > maxStrana)
            strana = 1;

        var model = new UbytovaniModel[20];

        for (var i = 0; i < model.Length; i++)
        {
            model[i] = new UbytovaniModel
            {
                UbytovaniId = _converter.Encode(i),
                Nazev = "aohisdnyv",
                Popis =
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus finibus consequat diam at varius. Maecenas vitae tortor dolor. Ut at finibus velit. Aenean id fringilla eros. Nullam fermentum at turpis eget pellentesque. Duis ut eleifend magna, at interdum nisl. Pellentesque lectus justo, accumsan et rhoncus nec, vehicula tempus turpis. Quisque porttitor, mauris sit amet malesuada mollis, metus felis finibus nulla, at auctor nisl libero at nisl. Nullam efficitur ultrices velit, vitae vestibulum enim vulputate volutpat. Nam condimentum quam nulla, eu blandit leo pretium in. Phasellus iaculis fermentum aliquam. Suspendisse tincidunt molestie enim non sagittis.",
                PocetHvezd = 5,
                Adresa = new AdresaModel
                {
                    AdresaId = "alsc",
                    Ulice = "alsc",
                    CisloPopisne = "alsc",
                    Mesto = "alsc",
                    Psc = "alsc"
                },
                ObrazkyUbytovani = Array.Empty<ObrazkyUbytovaniModel>()
            };
        }

        ViewBag.Strana = strana;
        ViewBag.MaxStrana = maxStrana;

        return View(model);
    }

    [HttpGet]
    [Route("ubytovani/{id}")]
    public IActionResult UbytovaniEdit(string id)
    {
        UbytovaniModel? model = null;

        ViewBag.Staty = new[]
        {
            new StatModel
            {
                StatId = "asdh",
                Zkratka = "CZ",
                Nazev = "Česká republika"
            },
            new StatModel
            {
                StatId = "1",
                Zkratka = "CZ1",
                Nazev = "Česká republika 1"
            },
            new StatModel
            {
                StatId = "asdh",
                Zkratka = "CZ2",
                Nazev = "Česká republika 2"
            },
            new StatModel
            {
                StatId = "asdh",
                Zkratka = "CZ3",
                Nazev = "Česká republika 3"
            },
        };

        if (id == "0")
        {
            return View(null);
        }

        if (_converter.Decode(id) > 0)
        {
            model = new UbytovaniModel
            {
                UbytovaniId = "éíýhfgd",
                Nazev = "aohisdnyv",
                Popis =
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus finibus consequat diam at varius. Maecenas vitae tortor dolor. Ut at finibus velit. Aenean id fringilla eros. Nullam fermentum at turpis eget pellentesque. Duis ut eleifend magna, at interdum nisl. Pellentesque lectus justo, accumsan et rhoncus nec, vehicula tempus turpis. Quisque porttitor, mauris sit amet malesuada mollis, metus felis finibus nulla, at auctor nisl libero at nisl. Nullam efficitur ultrices velit, vitae vestibulum enim vulputate volutpat. Nam condimentum quam nulla, eu blandit leo pretium in. Phasellus iaculis fermentum aliquam. Suspendisse tincidunt molestie enim non sagittis.",
                PocetHvezd = 5,
                Adresa = new AdresaModel
                {
                    AdresaId = "alsc",
                    Ulice = "alsc",
                    CisloPopisne = "alsc",
                    Mesto = "alsc",
                    Psc = "alsc",
                    Stat = new StatModel
                    {
                        StatId = "1",
                        Zkratka = null,
                        Nazev = null
                    }
                },
                ObrazkyUbytovani = new[]
                {
                    new ObrazkyUbytovaniModel
                    {
                        ObrazkyUbytovaniId = "yoxc",
                        Obrazek = Array.Empty<byte>(),
                        Nazev = "pepa.jpg"
                    },
                    new ObrazkyUbytovaniModel
                    {
                        ObrazkyUbytovaniId = "ias",
                        Obrazek = Array.Empty<byte>(),
                        Nazev = "pepa2.jpg"
                    }
                }
            };
        }

        return View(model);
    }

    [HttpPost]
    [Route("ubytovani")]
    public IActionResult UbytovaniPost([FromForm] UbytovaniModel model)
    {
        var newPhotos = new List<ObrazkyUbytovaniModel>();
        foreach (var file in Request.Form.Files)
        {
            var ms = new MemoryStream();
            file.CopyTo(ms);
            newPhotos.Add(new ObrazkyUbytovaniModel
            {
                ObrazkyUbytovaniId = null,
                Nazev = file.Name,
                Obrazek = ms.ToArray()
            });
        }

        return Ok();
    }

    // Zájezd
    [HttpGet]
    [Route("zajezd")]
    public IActionResult Zajezd(
        string ubytovani = "",
        string adresa = "",
        int cenaOd = 0,
        int cenaDo = int.MaxValue,
        int slevaOd = 0,
        int slevaDo = 100,
        string doprava = "",
        string strava = "",
        int strana = 1
    )
    {
        var maxStrana = 3;

        if (strana < 1 || strana > maxStrana)
            strana = 1;

        var model = new ZajezdModel[20];

        for (var i = 0; i < model.Length; i++)
        {
            model[i] = new ZajezdModel
            {
                ZajezdId = _converter.Encode(i),
                CenaZaOsobu = 6943,
                Zobrazit = true,
                Terminy = new[]
                {
                    new TerminModel
                    {
                        TerminId = "pou",
                        Od = default,
                        Do = default,
                        PokojeTerminu = new[]
                        {
                            new PokojTerminu
                            {
                                CelkovyPocetPokoju = 5,
                                PocetObsazenychPokoju = 3,
                                Pokoj = new PokojModel
                                {
                                    PokojId = "yjhcf",
                                    PocetMist = 5,
                                    Nazev = "pepi"
                                }
                            },
                            new PokojTerminu
                            {
                                CelkovyPocetPokoju = 15,
                                PocetObsazenychPokoju = 6,
                                Pokoj = new PokojModel
                                {
                                    PokojId = "zytxcz",
                                    PocetMist = 3,
                                    Nazev = "pepi"
                                }
                            }
                        }
                    }
                },
                Ubytovani = new UbytovaniModel
                {
                    UbytovaniId = "oizca",
                    Nazev = "arnošt",
                    Popis = null,
                    PocetHvezd = 0,
                    Adresa = new AdresaModel
                    {
                        AdresaId = null,
                        Ulice = null,
                        CisloPopisne = null,
                        Mesto = "Praha",
                        Psc = null,
                        Poznamka = null,
                        Stat = new StatModel
                        {
                            StatId = null,
                            Zkratka = null,
                            Nazev = "Česká republika"
                        }
                    },
                    ObrazkyUbytovani = Array.Empty<ObrazkyUbytovaniModel>()
                },
                Doprava = new DopravaModel
                {
                    DopravaId = "myxbc",
                    Nazev = "letecky"
                },
                Strava = new StravaModel
                {
                    StravaId = "yxc",
                    Nazev = "polopenze"
                }
            };
        }

        ViewBag.Stravy = new[]
        {
            new StravaModel
            {
                StravaId = "1",
                Nazev = "popl"
            },
            new StravaModel
            {
                StravaId = "2",
                Nazev = "plná"
            },
            new StravaModel
            {
                StravaId = "3",
                Nazev = "all"
            }
        };

        ViewBag.Dopravy = new[]
        {
            new DopravaModel
            {
                DopravaId = "1",
                Nazev = "letadlo"
            },
            new DopravaModel
            {
                DopravaId = "2",
                Nazev = "bez"
            },
            new DopravaModel
            {
                DopravaId = "3",
                Nazev = "auto"
            }
        };

        ViewBag.Strana = strana;
        ViewBag.MaxStrana = maxStrana;

        return View(model);
    }

    [HttpGet]
    [Route("zajezd/{id}")]
    public IActionResult ZajezdEdit(string id)
    {
        ZajezdModel? model = null;

        ViewBag.Ubytovani = new[]
        {
            new UbytovaniModel
            {
                UbytovaniId = "1",
                Nazev = "Pepa 1",
                Popis = null,
                PocetHvezd = 0,
                Adresa = null,
                ObrazkyUbytovani = Array.Empty<ObrazkyUbytovaniModel>()
            },
            new UbytovaniModel
            {
                UbytovaniId = "2",
                Nazev = "Pepa 2",
                Popis = null,
                PocetHvezd = 0,
                Adresa = null,
                ObrazkyUbytovani = Array.Empty<ObrazkyUbytovaniModel>()
            }
        };

        ViewBag.Pokoje = new[]
        {
            new PokojModel
            {
                PokojId = "1",
                PocetMist = 1,
                Nazev = "solo"
            },
            new PokojModel
            {
                PokojId = "2",
                PocetMist = 2,
                Nazev = "dvoulůžko"
            },
            new PokojModel
            {
                PokojId = "3",
                PocetMist = 3,
                Nazev = "troj"
            }
        };

        ViewBag.Stravy = new[]
        {
            new StravaModel
            {
                StravaId = "1",
                Nazev = "popl"
            },
            new StravaModel
            {
                StravaId = "2",
                Nazev = "plná"
            },
            new StravaModel
            {
                StravaId = "3",
                Nazev = "all"
            }
        };

        ViewBag.Dopravy = new[]
        {
            new DopravaModel
            {
                DopravaId = "1",
                Nazev = "letadlo"
            },
            new DopravaModel
            {
                DopravaId = "2",
                Nazev = "bez"
            },
            new DopravaModel
            {
                DopravaId = "3",
                Nazev = "auto"
            }
        };

        if (id == "0")
        {
            return View(null);
        }

        if (_converter.Decode(id) > 0)
        {
            model = new ZajezdModel
            {
                ZajezdId = "ixyhc",
                CenaZaOsobu = 6943,
                Zobrazit = true,
                Terminy = new[]
                {
                    new TerminModel
                    {
                        TerminId = "pou",
                        Od = default,
                        Do = default,
                        PokojeTerminu = new[]
                        {
                            new PokojTerminu
                            {
                                CelkovyPocetPokoju = 5,
                                PocetObsazenychPokoju = 3,
                                Pokoj = new PokojModel
                                {
                                    PokojId = "2",
                                    PocetMist = 5,
                                    Nazev = "pepi"
                                }
                            },
                            new PokojTerminu
                            {
                                CelkovyPocetPokoju = 15,
                                PocetObsazenychPokoju = 6,
                                Pokoj = new PokojModel
                                {
                                    PokojId = "1",
                                    PocetMist = 3,
                                    Nazev = "pepi"
                                }
                            }
                        }
                    },
                    new TerminModel
                    {
                        TerminId = "aswvc",
                        Od = default,
                        Do = default,
                        PokojeTerminu = new[]
                        {
                            new PokojTerminu
                            {
                                CelkovyPocetPokoju = 5,
                                PocetObsazenychPokoju = 3,
                                Pokoj = new PokojModel
                                {
                                    PokojId = "2",
                                    PocetMist = 5,
                                    Nazev = "pepi"
                                }
                            }
                        }
                    }
                },
                Ubytovani = new UbytovaniModel
                {
                    UbytovaniId = "2",
                    Nazev = "arnošt",
                    Popis = null,
                    PocetHvezd = 0,
                    Adresa = new AdresaModel
                    {
                        AdresaId = null,
                        Ulice = null,
                        CisloPopisne = null,
                        Mesto = "Praha",
                        Psc = null,
                        Poznamka = null,
                        Stat = new StatModel
                        {
                            StatId = null,
                            Zkratka = null,
                            Nazev = "Česká republika"
                        }
                    },
                    ObrazkyUbytovani = Array.Empty<ObrazkyUbytovaniModel>()
                },
                Doprava = new DopravaModel
                {
                    DopravaId = "2",
                    Nazev = "letecky"
                },
                Strava = new StravaModel
                {
                    StravaId = "2",
                    Nazev = "polopenze"
                }
            };
        }

        return View(model);
    }

    [HttpPost]
    [Route("zajezd")]
    public IActionResult ZajezdPost([FromForm] ZajezdModel model)
    {
        return Ok();
    }

    // Objednávka
    [HttpGet]
    [Route("objednavka")]
    public IActionResult Objednavka(
        string zakaznik = "",
        string ubytovani = "",
        string zaplaceno = "",
        DateOnly datumOd = default,
        DateOnly datumDo = default,
        int cenaOd = int.MinValue,
        int cenaDo = int.MaxValue,
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

        var model = new ObjednavkaModel[20];

        for (var i = 0; i < model.Length; i++)
        {
            model[i] = new ObjednavkaModel
            {
                ObjednavkaId = _converter.Encode(i),
                PocetOsob = 3,
                Osoby = new[]
                {
                    new OsobaModel
                    {
                        OsobaId = "lyhas",
                        Jmeno = "pepa",
                        Prijmeni = "zdepa",
                        DatumNarozeni = default
                    },
                    new OsobaModel
                    {
                        OsobaId = "yxv",
                        Jmeno = "pepa 2",
                        Prijmeni = "zdepa",
                        DatumNarozeni = default
                    }
                },
                Zakaznik = new ZakaznikModel
                {
                    ZakaznikId = "ylixc",
                    PrihlasovaciUdaje = new PrihlasovaciUdajeModel
                    {
                        PrihlasovaciUdajeId = null,
                        Jmeno = "pepa123",
                        Heslo = null
                    },
                    Osoba = new OsobaModel
                    {
                        OsobaId = "asd",
                        Jmeno = "Anošt",
                        Prijmeni = "zdepa",
                        DatumNarozeni = default
                    },
                    Kontakt = null,
                    Adresa = null
                },
                Termin = new TerminModel
                {
                    TerminId = "yxkcjv",
                    Od = default,
                    Do = default,
                    PokojeTerminu = null
                },
                Pokoj = new PokojModel
                {
                    PokojId = "kzyv",
                    PocetMist = 3,
                    Nazev = "troj"
                },
                Zajezd = new ZajezdModel
                {
                    ZajezdId = "yi",
                    CenaZaOsobu = 9435,
                    Zobrazit = false,
                    Terminy = null,
                    Ubytovani = new UbytovaniModel
                    {
                        UbytovaniId = "yhv",
                        Nazev = "hotel ygor",
                        PocetHvezd = 3,
                        Adresa = null,
                        ObrazkyUbytovani = Array.Empty<ObrazkyUbytovaniModel>()
                    },
                    Doprava = null,
                    Strava = null
                },
                Platba = new PlatbaModel
                {
                    PlatbaId = "olyihjc",
                    Castka = 87321,
                    CisloUctu = "",
                    Zaplacena = false
                },
                Pojisteni = new PojisteniModel
                {
                    PojisteniId = "yxiku",
                    CenaZaDen = 56,
                    Nazev = "pepa"
                }
            };
        }

        ViewBag.Strana = strana;
        ViewBag.MaxStrana = maxStrana;

        return View(model);
    }

    [HttpGet]
    [Route("objednavka/{id}")]
    public IActionResult ObjednavkaEdit(string id)
    {
        if (id == "0")
        {
            return View(null);
        }

        ObjednavkaModel? model = null;

        if (_converter.Decode(id) > 0)
        {
            model = new ObjednavkaModel
            {
                ObjednavkaId = "kyxuc",
                PocetOsob = 3,
                Osoby = new[]
                {
                    new OsobaModel
                    {
                        OsobaId = "lyhas",
                        Jmeno = "pepa",
                        Prijmeni = "zdepa",
                        DatumNarozeni = default
                    },
                    new OsobaModel
                    {
                        OsobaId = "yxv",
                        Jmeno = "pepa 2",
                        Prijmeni = "zdepa",
                        DatumNarozeni = default
                    }
                },
                Zakaznik = new ZakaznikModel
                {
                    ZakaznikId = "ylixc",
                    PrihlasovaciUdaje = new PrihlasovaciUdajeModel
                    {
                        PrihlasovaciUdajeId = null,
                        Jmeno = "pepa123",
                        Heslo = null
                    },
                    Osoba = new OsobaModel
                    {
                        OsobaId = "asd",
                        Jmeno = "Anošt",
                        Prijmeni = "zdepa",
                        DatumNarozeni = default
                    },
                    Kontakt = null,
                    Adresa = null
                },
                Termin = new TerminModel
                {
                    TerminId = "yxkcjv",
                    Od = default,
                    Do = default,
                    PokojeTerminu = null
                },
                Pokoj = new PokojModel
                {
                    PokojId = "kzyv",
                    PocetMist = 3,
                    Nazev = "troj"
                },
                Zajezd = new ZajezdModel
                {
                    ZajezdId = "yi",
                    CenaZaOsobu = 9435,
                    Zobrazit = false,
                    Terminy = null,
                    Ubytovani = new UbytovaniModel
                    {
                        UbytovaniId = "yhv",
                        Nazev = "hotel ygor",
                        PocetHvezd = 3,
                        Adresa = null,
                        ObrazkyUbytovani = Array.Empty<ObrazkyUbytovaniModel>()
                    },
                    Doprava = null,
                    Strava = null
                },
                Platba = new PlatbaModel
                {
                    PlatbaId = "olyihjc",
                    Castka = 87321,
                    CisloUctu = null,
                    Zaplacena = false
                },
                Pojisteni = new PojisteniModel
                {
                    PojisteniId = "yxiku",
                    CenaZaDen = 56,
                    Nazev = "pepa"
                }
            };
        }

        return View(model);
    }

    [HttpPost]
    [Route("objednavka")]
    public IActionResult ObjednavkaPost([FromForm] ObjednavkaModel model)
    {
        return Ok();
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

        ViewBag.Role = new[]
        {
            new RoleModel
            {
                RoleId = "",
                Nazev = "Všechny"
            },
            new RoleModel
            {
                RoleId = "8TwqJ",
                Nazev = "Zaměstnanec"
            },
            new RoleModel
            {
                RoleId = "jkMvT",
                Nazev = "Admin"
            }
        };

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