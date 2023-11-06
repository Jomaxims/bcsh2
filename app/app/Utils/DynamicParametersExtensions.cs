using System.Data;
using System.Text.Json;
using app.DAL;
using Dapper;

namespace app.Utils;

public static class DynamicParametersExtensions
{
    public static DynamicParameters AddId(this DynamicParameters parameters, string tableName, int? id)
    {
        parameters.Add($"p_{tableName}_id", id, dbType: DbType.Int32, direction: ParameterDirection.InputOutput);

        return parameters;
    }
    
    public static DynamicParameters AddResult(this DynamicParameters parameters)
    {
        parameters.Add("o_result", dbType: DbType.String, direction: ParameterDirection.Output, size: 1000);
        
        return parameters;
    }
    
    public static DbResult GetResult(this DynamicParameters parameters)
    {
        return JsonSerializer.Deserialize<DbResult>(parameters.Get<string>("o_result"))!.AddId(GetId(parameters));
    }

    private static int GetId(DynamicParameters parameters)
    {
        return parameters.Get<int>(parameters.ParameterNames.First(p => p.EndsWith("_id")));
    }
}