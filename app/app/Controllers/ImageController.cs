using System.Drawing;
using System.Net;
using System.Net.Http.Headers;
using app.Utils;
using Microsoft.AspNetCore.Mvc;
using Sqids;

namespace app.Controllers;

public class ImageController : Controller
{
    private readonly IIdConverter _converter;

    public ImageController(IIdConverter converter)
    {
        _converter = converter;
    }
    
    [Route("images/{id}")]
    [ResponseCache(VaryByHeader = "User-Agent", Duration = 30)]
    public IActionResult Index(string id)
    {
        using var img = Image.FromFile("./sample.jpg");
        var imgByteArr = new ImageConverter().ConvertTo(img, typeof(byte[])) as byte[];
        
        return File(imgByteArr!, "image/jpeg");
    }
}