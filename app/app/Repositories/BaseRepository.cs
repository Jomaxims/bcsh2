using app.DAL;
using app.DAL.Models;
using app.Utils;

namespace app.Repositories;

/// <summary>
/// Metoda pro převádění doménových modelů do databázových.
/// </summary>
/// <typeparam name="TDto">Typ databázového modelu</typeparam>
/// <typeparam name="TModel">Typ doménového modelu</typeparam>
public delegate TDto MapModelToDto<out TDto, in TModel>(TModel model) where TDto : IDbModel;

/// <summary>
/// Metoda pro převádění databázových modelů do doménových.
/// </summary>
/// <typeparam name="TDto">Typ databázového modelu</typeparam>
/// <typeparam name="TModel">Typ doménového modelu</typeparam>
public delegate TModel MapDtoToModel<out TModel, in TDto>(TDto dto) where TDto : IDbModel;

/// <summary>
/// Vyjímka pro práci s databází.
/// </summary>
public class DatabaseException : Exception
{
    public DatabaseException()
    {
    }

    public DatabaseException(string? message) : base(message)
    {
    }

    public DatabaseException(string? message, Exception? innerException) : base(message, innerException)
    {
    }
}

/// <summary>
/// Základní třída pro všechny repository. Obsahuje základní funkce pro manipulaci s objekty.
/// </summary>
public abstract class BaseRepository
{
    private readonly IIdConverter _idConverter;
    protected readonly ILogger Logger;
    protected readonly IDbUnitOfWork UnitOfWork;
    
    protected BaseRepository(ILogger logger, IDbUnitOfWork unitOfWork, IIdConverter idConverter)
    {
        Logger = logger;
        UnitOfWork = unitOfWork;
        _idConverter = idConverter;
    }

    /// <summary>
    /// Zakóduje dané id pomocí daného IIdConverter
    /// </summary>
    /// <param name="id">id</param>
    /// <returns>Zakódované id nebo null</returns>
    protected string EncodeId(int? id)
    {
        return id == null ? string.Empty : _idConverter.Encode(id.Value);
    }

    /// <summary>
    /// Zakóduje dané id pomocí daného IIdConverter
    /// </summary>
    /// <param name="id">id</param>
    /// <returns>Zakódované id</returns>
    protected string EncodeId(string id)
    {
        return _idConverter.Encode(id);
    }

    /// <summary>
    /// Dekóduje dané id pomocí daného IIdConverter
    /// </summary>
    /// <param name="id">Zakódované id</param>
    /// <returns>Dekódované id nebo null</returns>
    protected int? DecodeId(string? id)
    {
        if (string.IsNullOrEmpty(id))
            return null;

        var actualId = _idConverter.Decode(id);

        return actualId != 0 ? actualId : null;
    }

    /// <summary>
    /// Dekóduje dané id pomocí daného IIdConverter
    /// </summary>
    /// <param name="id">Zakódované id</param>
    /// <returns>Dekódované id nebo 0</returns>
    protected int DecodeIdOrDefault(string id, int defaultId = 0)
    {
        return DecodeId(id) ?? defaultId;
    }

    /// <summary>
    /// Uloží model do db pomocí dao
    /// </summary>
    /// <param name="dao">DAO pro danou tabulku</param>
    /// <param name="model">Doménový model</param>
    /// <param name="mapper">Převodník modelů</param>
    /// <returns>id položky v databázi</returns>
    /// <exception cref="DatabaseException">Pokud se nepodaří položku přidat</exception>
    protected int AddOrEdit<TDto, TModel>(GenericDao<TDto> dao, TModel model, MapModelToDto<TDto, TModel> mapper)
        where TDto : IDbModel
    {
        try
        {
            var dto = mapper(model);
            var result = dao.AddOrEdit(dto);

            result.IsOkOrThrow();

            return result.Id;
        }
        catch (Exception e)
        {
            Logger.Log(LogLevel.Error, "{}", e);
            throw new DatabaseException("Položku se nepodařilo přidat/upravit", e);
        }
    }

    /// <summary>
    /// Smaže položku z db pomocí dao
    /// </summary>
    /// <param name="dao">DAO pro danou tabulku</param>
    /// <param name="id">id položky</param>
    /// <exception cref="DatabaseException">Pokud se nepodaří položku smazat</exception>
    protected void Delete<T>(GenericDao<T> dao, int id) where T : IDbModel
    {
        try
        {
            var result = dao.Delete(id);

            result.IsOkOrThrow();
        }
        catch (Exception e)
        {
            Logger.Log(LogLevel.Error, "{}", e);
            if (e.Message.Contains("ORA-02292"))
                throw new DatabaseException("Položka je využívána. Pro smazání položky smažte všechny závislé položky",
                    e);

            throw new DatabaseException("Položku se nepodařilo smazat", e);
        }
    }

    /// <summary>
    /// Dostane položku z databáze pomocí dao
    /// </summary>
    /// <param name="dao">DAO pro danou tabulku</param>
    /// <param name="id">id položky</param>
    /// <param name="mapper">Převodník modelů</param>
    /// <returns>Položku jako doménový model</returns>
    /// <exception cref="DatabaseException">Pokud se nepodaří položku najít</exception>
    protected TModel Get<TModel, TDto>(GenericDao<TDto> dao, int id, MapDtoToModel<TModel, TDto> mapper)
        where TDto : IDbModel
    {
        try
        {
            var result = dao.Get(id);

            return mapper(result);
        }
        catch (Exception e)
        {
            Logger.Log(LogLevel.Error, "{}", e);
            throw new DatabaseException("Položku se nepodařilo načíst", e);
        }
    }

    /// <summary>
    /// Dostane všechny položky typu z databáze pomocí dao
    /// </summary>
    /// <param name="dao">DAO pro danou tabulku</param>
    /// <param name="mapper">Převodník modelů</param>
    /// <returns>Všechny položky v tabulce</returns>
    protected static IEnumerable<TModel> GetAll<TModel, TDto>(GenericDao<TDto> dao, MapDtoToModel<TModel, TDto> mapper)
        where TDto : IDbModel
    {
        var result = dao.GetAll();

        return result.Select(item => mapper(item));
    }
}