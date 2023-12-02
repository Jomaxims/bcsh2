using System.Data;
using System.Text;
using System.Text.Json;
using app.DAL;
using Dapper;

namespace app.Utils;

/// <summary>
/// Extensions pro Dapper DynamicParameters
/// </summary>
public static class DynamicParametersExtensions
{
    /// <summary>
    /// Přidá výstupní parametr o_result do parametrý
    /// </summary>
    /// <param name="parameters"></param>
    /// <returns></returns>
    public static DynamicParameters AddResult(this DynamicParameters parameters)
    {
        parameters.Add("o_result", dbType: DbType.String, direction: ParameterDirection.Output, size: 10000);

        return parameters;
    }

    /// <summary>
    /// Získá DbResult z parametru o_result
    /// </summary>
    /// <param name="parameters"></param>
    /// <returns></returns>
    public static DbResult GetResult(this DynamicParameters parameters)
    {
        var json = parameters.Get<string>("o_result");
        var id = GetId(parameters);
        const string msgName = "\"message\": \"";
        var startOfMessage = json.IndexOf(msgName, StringComparison.Ordinal) + msgName.Length;
        var strBuilder = new StringBuilder();

        strBuilder.Append(json[..startOfMessage]);
        strBuilder.Append(json[startOfMessage..^3].Replace("\"", "\\\""));
        strBuilder.Append(json[^3..]);

        return JsonSerializer.Deserialize<DbResult>(strBuilder.ToString())!.AddId(id);
    }

    /// <summary>
    /// Získá id z parametrů
    /// </summary>
    /// <param name="parameters"></param>
    /// <returns></returns>
    private static int GetId(DynamicParameters parameters)
    {
        return parameters.Get<int>(parameters.ParameterNames.First(p => p.EndsWith("_id")));
    }
}