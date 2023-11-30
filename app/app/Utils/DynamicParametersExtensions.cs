using System.Data;
using System.Text;
using System.Text.Json;
using app.DAL;
using Dapper;

namespace app.Utils;

public static class DynamicParametersExtensions
{
    public static DynamicParameters AddResult(this DynamicParameters parameters)
    {
        parameters.Add("o_result", dbType: DbType.String, direction: ParameterDirection.Output, size: 10000);
        
        return parameters;
    }
    
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

    private static int GetId(DynamicParameters parameters)
    {
        return parameters.Get<int>(parameters.ParameterNames.First(p => p.EndsWith("_id")));
    }
}