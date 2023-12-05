using Microsoft.AspNetCore.Mvc;

namespace app.ViewComponents;

/// <summary>
/// ViewComponent pro navbar
/// </summary>
public class NavbarViewComponent : ViewComponent
{
    public IViewComponentResult Invoke()
    {
        return View();
    }
}