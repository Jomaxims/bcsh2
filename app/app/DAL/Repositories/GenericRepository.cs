using System.Data;
using Dapper;
using System.Text.Json;
using app.DAL.Models;
using app.Utils;

namespace app.DAL.Repositories;

public class GenericRepository : RepositoryBase
{
    public GenericRepository(IDbUnitOfWork unitOfWork) : base(unitOfWork)
    {
    }

    public DbResult Delete(string tableName, int id)
    {
        var parameters = new DynamicParameters();
        parameters.AddId(tableName, id);
        parameters.AddResult();

        UnitOfWork.Connection.Query($"pck_{tableName}.delete_{tableName}", parameters, commandType: CommandType.StoredProcedure);

        return parameters.GetResult();
    }
    
    public DbResult Edit(DbModel dbModel)
    {
        var tableName = dbModel.GetType().Name.ToLower();
        var parameters = MapModelToParams(dbModel);
        
        UnitOfWork.Connection.Query($"pck_{tableName}.manage_{tableName}", parameters, commandType: CommandType.StoredProcedure);
        
        return parameters.GetResult();
    }

    public IEnumerable<T> Get<T>(int id) where T : DbModel
    {
        var tableName = typeof(T).Name;
        var sql = $"SELECT * FROM {tableName} WHERE {tableName}_id = :id";

        return UnitOfWork.Connection.Query<T>(sql, new { id });
    }

    private static DynamicParameters MapModelToParams(DbModel model, string prefix = "p_")
    {
        var ignored = new[] { "id" };
        var parameters = new DynamicParameters();
        var tableName = model.GetType().Name.ToLower();
        var properties = model.GetType().GetProperties().Where(prop => !ignored.Contains(prop.Name.ToLower()));

        parameters.Add($"{prefix}{tableName}_id", model.Id);
        parameters.AddResult();
        foreach (var property in properties)
        {
            parameters.Add($"p_{property.Name.ToLower()}", property.GetValue(model));
        }

        return parameters;
    }
}