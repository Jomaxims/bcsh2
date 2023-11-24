using app.Models;
using Microsoft.AspNetCore.Mvc;

namespace app.ViewComponents;

public class ObjednavkaPlatbaViewComponent : ViewComponent
{
    public IViewComponentResult Invoke()
    {
        var model = new ObjednavkaPlatbaModel
        {
            CisloKarty = "",
            DatumPlatnosti = "",
            Cvv = ""
        };
        return View(model);
    }
}