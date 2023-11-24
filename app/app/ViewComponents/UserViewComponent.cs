using app.Models;
using Microsoft.AspNetCore.Mvc;

namespace app.ViewComponents;

public class UserViewComponent : ViewComponent
{
    public IViewComponentResult Invoke()
    {
        return View();
    }
}