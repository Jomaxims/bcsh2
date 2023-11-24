using System.Data;
using System.Text.Json;
using app.DAL;
using Dapper;

namespace app.Utils;

public static class DynamicParametersExtensions
{
    public static DynamicParameters AddResult(this DynamicParameters parameters)
    {
        parameters.Add("o_result", dbType: DbType.String, direction: ParameterDirection.Output, size: 1000);
        
        return parameters;
    }
    
    public static DbResult GetResult(this DynamicParameters parameters)
    {
        var json = parameters.Get<string>("o_result");
        var id = GetId(parameters);
        return JsonSerializer.Deserialize<DbResult>(json)!.AddId(id);
    }

    private static int? GetId(DynamicParameters parameters)
    {
        return parameters.Get<int?>(parameters.ParameterNames.First(p => p.EndsWith("_id")));
    }
}