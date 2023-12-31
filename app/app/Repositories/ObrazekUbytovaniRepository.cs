﻿using System.Data;
using System.Text;
using System.Text.Json;
using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;
using Dapper;
using Oracle.ManagedDataAccess.Client;
using Oracle.ManagedDataAccess.Types;

namespace app.Repositories;

/// <summary>
/// Repository pro práci s obrázky ubytování
/// </summary>
public class ObrazekUbytovaniRepository : BaseRepository
{
    private readonly GenericDao<ObrazkyUbytovani> _obrazekUbytovaniDao;

    public ObrazekUbytovaniRepository(
        ILogger<ObrazekUbytovaniRepository> logger,
        IDbUnitOfWork unitOfWork,
        IIdConverter idConverter,
        GenericDao<ObrazkyUbytovani> obrazekUbytovaniDao
    ) : base(logger, unitOfWork, idConverter)
    {
        _obrazekUbytovaniDao = obrazekUbytovaniDao;
    }

    /// <summary>
    /// Zda repository spravuje vlastní transakce
    /// </summary>
    public bool TransactionsManaged { get; set; } = false;

    /// <summary>
    /// Přidá nebo upraví (pokud mí id) obrázek ubytování
    /// </summary>
    /// <param name="model">Obrázek</param>
    /// <param name="ubytovaniId">id ubytování</param>
    /// <returns></returns>
    /// <exception cref="DatabaseException">Pokud nastala chyba při vkládání</exception>
    public int AddOrEdit(ObrazkyUbytovaniModel model, int ubytovaniId)
    {
        if (!TransactionsManaged) UnitOfWork.BeginTransaction();

        try
        {
            var command = new OracleCommand();
            command.CommandText = "pck_obrazky_ubytovani.manage_obrazky_ubytovani";
            command.Connection = (OracleConnection)UnitOfWork.Connection;
            command.CommandType = CommandType.StoredProcedure;

            var param = command.Parameters.Add("p_obrazky_ubytovani_id", OracleDbType.Int32,
                ParameterDirection.InputOutput);
            param = command.Parameters.Add("p_obrazek", OracleDbType.Blob, ParameterDirection.Input);
            param.Value = model.Obrazek;
            param = command.Parameters.Add("p_nazev", OracleDbType.Varchar2, ParameterDirection.Input);
            param.Value = model.Nazev;
            param = command.Parameters.Add("p_ubytovani_id", OracleDbType.Int32, ParameterDirection.Input);
            param.Value = ubytovaniId;
            param = command.Parameters.Add("o_result", OracleDbType.Clob, ParameterDirection.Output);

            command.ExecuteNonQuery();

            var json = ((OracleClob)command.Parameters["o_result"].Value!).Value;
            var id = ((OracleDecimal)command.Parameters["p_obrazky_ubytovani_id"].Value).ToInt32();
            const string msgName = "\"message\": \"";
            var startOfMessage = json.IndexOf(msgName, StringComparison.Ordinal) + msgName.Length;
            var strBuilder = new StringBuilder();

            strBuilder.Append(json[..startOfMessage]);
            strBuilder.Append(json[startOfMessage..^3].Replace("\"", "\\\""));
            strBuilder.Append(json[^3..]);

            var result = JsonSerializer.Deserialize<DbResult>(strBuilder.ToString())!.AddId(id);

            result.IsOkOrThrow();

            if (!TransactionsManaged) UnitOfWork.Commit();
            return result.Id;
        }
        catch (Exception e)
        {
            if (!TransactionsManaged) UnitOfWork.Rollback();

            Logger.Log(LogLevel.Error, "{}", e);
            throw new DatabaseException("Položku se nepodařilo přidat/upravit", e);
        }
    }

    /// <summary>
    /// Smaže obrázek ubytování
    /// </summary>
    /// <param name="id">id obrázku</param>
    public void Delete(int id)
    {
        Delete(_obrazekUbytovaniDao, id);
    }

    /// <summary>
    /// Získá obrázek ubytování
    /// </summary>
    /// <param name="id">id obrázku</param>
    /// <returns>Obrázek</returns>
    public ObrazkyUbytovaniModel Get(int id)
    {
        const string sql = """
                             select * from OBRAZKY_UBYTOVANI
                                  where OBRAZKY_UBYTOVANI_ID = :id
                           """;

        var dto = UnitOfWork.Connection.QuerySingle<ObrazkyUbytovani>(sql, new { id });

        return MapToModel(dto);
    }

    /// <summary>
    /// Získá id obrázků ubytování dle ubytování
    /// </summary>
    /// <param name="ubytovaniId">id ubytování</param>
    /// <returns>id obrázků</returns>
    public IEnumerable<int> GetObrazkyUbytovaniIdsByUbytovani(int ubytovaniId)
    {
        const string sql = """
                             select OBRAZKY_UBYTOVANI_ID from OBRAZKY_UBYTOVANI
                                  where UBYTOVANI_ID = :ubytovaniId
                           """;

        var dto = UnitOfWork.Connection.Query<int>(sql, new { ubytovaniId });

        return dto;
    }

    /// <summary>
    /// Mapovací funkce
    /// </summary>
    /// <param name="dto"></param>
    /// <returns></returns>
    private ObrazkyUbytovaniModel MapToModel(ObrazkyUbytovani dto)
    {
        return new ObrazkyUbytovaniModel
        {
            ObrazkyUbytovaniId = EncodeId(dto.ObrazkyUbytovaniId),
            Nazev = dto.Nazev,
            Obrazek = dto.Obrazek
        };
    }
}