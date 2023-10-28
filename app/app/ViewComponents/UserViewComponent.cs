using app.Models;
using Microsoft.AspNetCore.Mvc;

namespace app.ViewComponents;

public class UserViewComponent : ViewComponent
{
    public async Task<IViewComponentResult> InvokeAsync(SignUpViewModel model)
    {
        return View(model);
    }
}