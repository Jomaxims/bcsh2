using System.Web;

namespace app.Utils;

// https://stackoverflow.com/a/28169599
public static class UriExtensions
{
    public static Uri SetQueryVal(this Uri uri, string name, object value)
    {
        var nvc = HttpUtility.ParseQueryString(uri.Query);
        nvc[name] = (value ?? "").ToString();
        return new UriBuilder(uri) {Query = nvc.ToString()}.Uri;
    }
}