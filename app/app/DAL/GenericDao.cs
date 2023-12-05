using System.Data;
using app.DAL.Models;
using app.Utils;
using Dapper;
using Humanizer;
using Oracle.ManagedDataAccess.Client;

namespace app.DAL;

/// <summary>
/// Generické DAO pro práci s tabulkami.
/// </summary>
/// <typeparam name="T">Typ dané tabulky</typeparam>
public class GenericDao<T> where T : IDbModel
{
    private static readonly string TableName = typeof(T).Name.Underscore().ToLower();
    private readonly IDbUnitOfWork _unitOfWork;

    public GenericDao(IDbUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    /// <summary>
    /// Smaže záznam z tabulky dle id pomocí příslušné procedury.
    /// </summary>
    /// <param name="id">id záznamu</param>
    /// <returns></returns>
    public DbResult Delete(int id)
    {
        var parameters = new DynamicParameters();
        parameters.Add($"{Constants.DbProcedureParamPrefix}{TableName}_id", id);
        parameters.AddResult();

        _unitOfWork.Connection.Query($"pck_{TableName}.delete_{TableName}", parameters,
            commandType: CommandType.StoredProcedure);

        return parameters.GetResult();
    }

    /// <summary>
    /// Přidá nebo změní (pokud má id) záznam v databázi pomocí příslušné procedury.
    /// </summary>
    /// <param name="model">Databázový model záznamu</param>
    /// <returns></returns>
    public DbResult AddOrEdit(T model)
    {
        var parameters = MapModelToParams(model);

        var res = _unitOfWork.Connection.Execute($"pck_{TableName}.manage_{TableName}", parameters,
            commandType: CommandType.StoredProcedure);

        return parameters.GetResult();
    }

    /// <summary>
    /// Získá záznam z databáze
    /// </summary>
    /// <param name="id">id záznamu</param>
    /// <returns></returns>
    public T Get(int id)
    {
        var sql = $"SELECT * FROM {TableName} WHERE {TableName}_id = :id";

        return _unitOfWork.Connection.QuerySingle<T>(sql, new { id });
    }

    /// <summary>
    /// Získá všechny záznamy z dané tabulky
    /// </summary>
    /// <returns></returns>
    public IEnumerable<T> GetAll()
    {
        var sql = $"SELECT * FROM {TableName}";

        return _unitOfWork.Connection.Query<T>(sql);
    }

    /// <summary>
    /// Funkce pro mapování databázového modelu do parametrů pro databázové procedury.
    /// </summary>
    /// <param name="model">Databázový model</param>
    /// <returns></returns>
    private static DynamicParameters MapModelToParams(T model)
    {
        var parameters = new DynamicParameters();

        foreach (var property in typeof(T).GetProperties())
        {
            var propName = $"{Constants.DbProcedureParamPrefix}{property.Name.Underscore().ToLower()}";

            if (propName.EndsWith("_id"))
            {
                parameters.Add(propName, property.GetValue(model), DbType.Int32, ParameterDirection.InputOutput);
            }
            else
            {
                if (property.PropertyType == typeof(DateOnly))
                {
                    var dateOnly = (DateOnly)property.GetValue(model)!;
                    var dateTime = dateOnly.ToDateTime(new TimeOnly(0, 0));
                    parameters.Add(propName, dateTime, OracleDbType.Date as DbType?);
                }
                else if (property.PropertyType == typeof(byte[]))
                {
                    parameters.Add(propName, property.GetValue(model), DbType.Binary);
                }
                else if (property.PropertyType == typeof(bool))
                {
                    var value = (bool)property.GetValue(model) ? 1 : 0;
                    parameters.Add(propName, value, DbType.Int32);
                }
                else
                {
                    parameters.Add(propName, property.GetValue(model));
                }
            }
        }

        parameters.AddResult();

        return parameters;
    }
}