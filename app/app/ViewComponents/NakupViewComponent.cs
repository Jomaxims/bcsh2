﻿using app.Models;
using Microsoft.AspNetCore.Mvc;

namespace app.ViewComponents;

public class NakupViewComponent : ViewComponent
{
    public IViewComponentResult Invoke()
    {
        return View(new ZajezdNakupModel
        {
            Termin = null,
            PocetOsob = 1,
            Pojisteni = null,
            Pokoj = null
        });
    }
}