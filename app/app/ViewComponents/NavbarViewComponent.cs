﻿using Microsoft.AspNetCore.Mvc;

namespace app.ViewComponents;

public class NavbarViewComponent : ViewComponent
{
    public IViewComponentResult Invoke()
    {
        return View();
    }
}