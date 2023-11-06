using app.Models;
using Microsoft.AspNetCore.Mvc;

namespace app.ViewComponents;

public class ZajezdNahledViewComponent : ViewComponent
{
    public IViewComponentResult Invoke(ZajezdNahledModel model)
    {
        return View(model);
    }
}