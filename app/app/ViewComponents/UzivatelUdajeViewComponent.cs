using app.Models.Sprava;
using Microsoft.AspNetCore.Mvc;

namespace app.ViewComponents;

/// <summary>
/// ViewComponent pro údaje uživatele
/// </summary>
public class UzivatelUdajeViewComponent : ViewComponent
{
    public IViewComponentResult Invoke(ZakaznikModel udaje)
    {
        return View(udaje);
    }
}