using app.Models;
using app.Models.Sprava;
using Microsoft.AspNetCore.Mvc;

namespace app.ViewComponents;

public class UzivatelUdajeViewComponent : ViewComponent
{
    public IViewComponentResult Invoke(ZakaznikModel udaje)
    {
        return View(udaje);
    }
}