using app.Models;
using Microsoft.AspNetCore.Mvc;

namespace app.ViewComponents;

/// <summary>
/// ViewComponent pro platbu objednávky
/// </summary>
public class ObjednavkaPlatbaViewComponent : ViewComponent
{
    public IViewComponentResult Invoke(string platbaId)
    {
        var model = new ObjednavkaPlatbaModel
        {
            CisloKarty = "",
            DatumPlatnosti = "",
            Cvv = "",
            PlatbaId = platbaId
        };

        return View(model);
    }
}