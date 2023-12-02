using System.Data;
using Dapper;

namespace app.Utils;

/// <summary>
/// Mapper pro převod DateOnly
/// </summary>
public class DapperSqlDateOnlyTypeHandler : SqlMapper.TypeHandler<DateOnly>
{
    public override void SetValue(IDbDataParameter parameter, DateOnly date)
    {
        parameter.Value = date.ToString("o");
    }

    public override DateOnly Parse(object value)
    {
        return DateOnly.FromDateTime((DateTime)value);
    }
}