﻿using System.Data;
using Dapper;

namespace app.Utils;

public class DapperSqlDateOnlyTypeHandler : SqlMapper.TypeHandler<DateOnly>
{
    public override void SetValue(IDbDataParameter parameter, DateOnly date) => parameter.Value = date.ToString("o");
    
    public override DateOnly Parse(object value) => DateOnly.FromDateTime((DateTime)value);
}