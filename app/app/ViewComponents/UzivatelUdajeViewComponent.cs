using app.Models;
using Microsoft.AspNetCore.Mvc;

namespace app.ViewComponents;

public class UzivatelUdajeViewComponent : ViewComponent
{
    public IViewComponentResult Invoke(UzivatelUdaje udaje)
    {
        return View(udaje);
    }
}