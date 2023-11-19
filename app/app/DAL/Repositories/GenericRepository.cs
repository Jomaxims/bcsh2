using System.Data;
using Dapper;
using app.DAL.Models;
using app.Utils;
using Humanizer;

namespace app.DAL.Repositories;

public class GenericRepository<T> : RepositoryBase where T : IDbModel
{
    private static readonly string TableName = typeof(T).Name.Underscore().ToLower();
    
    public GenericRepository(IDbUnitOfWork unitOfWork) : base(unitOfWork) {}

    public DbResult Delete(int id)
    {
        var parameters = new DynamicParameters();
        parameters.Add($"{Constants.DbProcedureParamPrefix}{TableName}_id", id);
        parameters.AddResult();

        UnitOfWork.Connection.Query($"pck_{TableName}.delete_{TableName}", parameters, commandType: CommandType.StoredProcedure);

        return parameters.GetResult();
    }
    
    public DbResult Edit(T model)
    {
        var parameters = MapModelToParams(model);
        
        var res = UnitOfWork.Connection.Execute($"pck_{TableName}.manage_{TableName}", parameters, commandType: CommandType.StoredProcedure);
        // res.Read();
        // res.Close();
        // res.Dispose();
        // UnitOfWork.Reset();
        
        return parameters.GetResult();
    }

    public T Get(int id)
    {
        var sql = $"SELECT * FROM {TableName} WHERE {TableName}_id = :id";

        return UnitOfWork.Connection.QuerySingle<T>(sql, new { id });
    }
    
    public IEnumerable<T> GetAll()
    {
        var sql = $"SELECT * FROM {TableName}";

        return UnitOfWork.Connection.Query<T>(sql);
    }

    private static DynamicParameters MapModelToParams(T model)
    {
        var parameters = new DynamicParameters();
        
        foreach (var property in typeof(T).GetProperties())
        {
            var propName = $"{Constants.DbProcedureParamPrefix}{property.Name.Underscore().ToLower()}";
            
            if (propName.EndsWith("_id"))
                parameters.Add(propName, property.GetValue(model), dbType: DbType.Int32, direction: ParameterDirection.InputOutput);
            else
                parameters.Add(propName, property.GetValue(model));
        }
        parameters.AddResult();

        return parameters;
    }
}