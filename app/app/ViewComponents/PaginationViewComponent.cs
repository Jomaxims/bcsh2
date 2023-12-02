using Microsoft.AspNetCore.Mvc;

namespace app.ViewComponents;

/// <summary>
/// ViewComponent pro stránkování
/// </summary>
public class PaginationViewComponent : ViewComponent
{
    public IViewComponentResult Invoke(int strana, int maxStrana)
    {
        return View(new { Strana = strana, MaxStrana = maxStrana });
    }
}