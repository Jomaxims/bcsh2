using app.DAL;
using app.DAL.Models;
using app.Utils;

namespace app.Repositories;

public delegate TDto MapModelToDto<out TDto, in TModel>(TModel model) where TDto : IDbModel;

public delegate TModel MapDtoToModel<out TModel, in TDto>(TDto dto) where TDto : IDbModel;

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

    protected string EncodeId(int? id)
    {
        return id == null ? string.Empty : _idConverter.Encode(id.Value);
    }

    protected string EncodeId(string id)
    {
        return _idConverter.Encode(id);
    }

    protected int? DecodeId(string? id)
    {
        if (string.IsNullOrEmpty(id))
            return null;

        var actualId = _idConverter.Decode(id);

        return actualId != 0 ? actualId : null;
    }

    protected int DecodeIdOrDefault(string id, int defaultId = 0)
    {
        return DecodeId(id) ?? defaultId;
    }

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

    protected static IEnumerable<TModel> GetAll<TModel, TDto>(GenericDao<TDto> dao, MapDtoToModel<TModel, TDto> mapper)
        where TDto : IDbModel
    {
        var result = dao.GetAll();

        return result.Select(item => mapper(item));
    }
}