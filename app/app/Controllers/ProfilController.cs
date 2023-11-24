using app.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace app.Controllers;

[Authorize(Policy = "Zakaznik")]
[Route("profil")]
public class ProfilController : Controller
{
    [Route("")]
    public IActionResult Profil()
    {
        var model = new ProfilModel
        {
            PrihlasovaciJmeno = "pepaZdepa",
            Udaje = new UzivatelUdaje
            {
                Jmeno = "Pepa",
                Prijmeni = "Zdepa",
                DatumNarozeni = new DateOnly(2000, 12, 11),
                Kontakt = new KontaktModel
                {
                    Email = "pepa@zdepa.pp",
                    Telefon = "38426126"
                },
                Adresa = new AdresaModel
                {
                    Ulice = "pepova",
                    CisloPopisne = "55",
                    Mesto = "Pepkov",
                    PSC = "96731"
                },
            },
            Zajezdy = new []
            {
                new ProfilModel.ZajezdModel
                {
                    Id = "asd",
                    Nazev = "pouasoi",
                    PocetHvezd = 3,
                    Od = new DateOnly(2023, 11, 12),
                    Do = new DateOnly(2023, 11, 19),
                    Cena = 91357,
                    Zaplaceno = false,
                    PlatbaId = "ykxjhzc"
                },
                new ProfilModel.ZajezdModel
                {
                    Id = "asd",
                    Nazev = "poui",
                    PocetHvezd = 3,
                    Od = new DateOnly(2023, 11, 12),
                    Do = new DateOnly(2023, 11, 19),
                    Cena = 9357,
                    Zaplaceno = true,
                    PlatbaId = "ykxjhzc"
                },
                new ProfilModel.ZajezdModel
                {
                    Id = "asd",
                    Nazev = "68793i",
                    PocetHvezd = 3,
                    Od = new DateOnly(2023, 11, 12),
                    Do = new DateOnly(2023, 11, 19),
                    Cena = 91357,
                    Zaplaceno = false,
                    PlatbaId = "ykxjhzc"
                },
                new ProfilModel.ZajezdModel
                {
                    Id = "asd",
                    Nazev = "éíýšly",
                    PocetHvezd = 3,
                    Od = new DateOnly(2023, 11, 12),
                    Do = new DateOnly(2023, 11, 19),
                    Cena = 91357,
                    Zaplaceno = false,
                    PlatbaId = "ykxjhzc"
                }
            }
        };
        
        return View(model);
    }

    [HttpPost]
    [Route("udaje")]
    public IActionResult UdajePost([FromForm] UzivatelUdaje udaje)
    {
        if (!ModelState.IsValid)
            return RedirectToAction("Profil");
        
        // TODO zapsat údaje
        
        return RedirectToAction("Profil");
    }
    
    [HttpPost]
    [Route("heslo")]
    public IActionResult HesloPost([FromForm] string heslo)
    {
        if (!ModelState.IsValid)
            return RedirectToAction("Profil");
        
        // TODO zapsat údaje
        
        return RedirectToAction("Profil");
    }
}