using app.Repositories;
using app.Utils;
using Microsoft.AspNetCore.Mvc;

namespace app.Controllers;

public class ImageController : Controller
{
    private readonly IIdConverter _converter;
    private readonly ILogger<ImageController> _logger;
    private readonly ObrazekUbytovaniRepository _obrazekUbytovaniRepository;

    public ImageController(ILogger<ImageController> logger, IIdConverter converter,
        ObrazekUbytovaniRepository obrazekUbytovaniRepository)
    {
        _logger = logger;
        _converter = converter;
        _obrazekUbytovaniRepository = obrazekUbytovaniRepository;
    }

    [Route("images/{id}")]
    [ResponseCache(VaryByHeader = "User-Agent", Duration = 30)]
    public IActionResult Index(string id)
    {
        try
        {
            var img = _obrazekUbytovaniRepository.Get(_converter.Decode(id));

            return File(img.Obrazek, "image/jpeg");
        }
        catch (Exception e)
        {
            _logger.Log(LogLevel.Warning, "{}", e);

            return Redirect("~/image/empty.jpg");
        }
    }
}