using app.Models;
using Microsoft.AspNetCore.Mvc;

namespace app.ViewComponents;

public class NavbarViewComponent : ViewComponent
{
    public async Task<IViewComponentResult> InvokeAsync(string role)
    {
        ViewData["Role"] = role;
        
        return View();
    }
}