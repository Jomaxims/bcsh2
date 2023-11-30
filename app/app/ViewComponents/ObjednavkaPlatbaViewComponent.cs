using app.Models;
using Microsoft.AspNetCore.Mvc;

namespace app.ViewComponents;

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