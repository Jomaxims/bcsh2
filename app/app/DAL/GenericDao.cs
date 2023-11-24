using System.Data;
using app.DAL.Models;
using app.Utils;
using Dapper;
using Humanizer;

namespace app.DAL;

public class GenericDao<T> where T : IDbModel
{
    private readonly IDbUnitOfWork _unitOfWork;
    private static readonly string TableName = typeof(T).Name.Underscore().ToLower();
    
    public GenericDao(IDbUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public DbResult Delete(int id)
    {
        var parameters = new DynamicParameters();
        parameters.Add($"{Constants.DbProcedureParamPrefix}{TableName}_id", id);
        parameters.AddResult();

        _unitOfWork.Connection.Query($"pck_{TableName}.delete_{TableName}", parameters, commandType: CommandType.StoredProcedure);

        return parameters.GetResult();
    }
    
    public DbResult AddOrEdit(T model)
    {
        var parameters = MapModelToParams(model);
        
        var res = _unitOfWork.Connection.Execute($"pck_{TableName}.manage_{TableName}", parameters, commandType: CommandType.StoredProcedure);
        // res.Read();
        // res.Close();
        // res.Dispose();
        // UnitOfWork.Reset();
        
        return parameters.GetResult();
    }

    public T Get(int id)
    {
        var sql = $"SELECT * FROM {TableName} WHERE {TableName}_id = :id";

        return _unitOfWork.Connection.QuerySingle<T>(sql, new { id });
    }
    
    public IEnumerable<T> GetAll()
    {
        var sql = $"SELECT * FROM {TableName}";

        return _unitOfWork.Connection.Query<T>(sql);
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