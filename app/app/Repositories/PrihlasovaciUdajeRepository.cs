using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;
using Dapper;

namespace app.Repositories;

public class PrihlasovaciUdajeRepository : BaseRepository
{
    private readonly GenericDao<PrihlasovaciUdaje> _prihlasovaciUdajeDao;

    public PrihlasovaciUdajeRepository(
        ILogger<PrihlasovaciUdajeRepository> logger,
        IDbUnitOfWork unitOfWork,
        IIdConverter idConverter,
        GenericDao<PrihlasovaciUdaje> prihlasovaciUdajeDao
    ) : base(logger, unitOfWork, idConverter)
    {
        _prihlasovaciUdajeDao = prihlasovaciUdajeDao;
    }

    public int AddOrEdit(PrihlasovaciUdajeModel model)
    {
        try
        {
            var dto = MapToDto(model);
            var result = _prihlasovaciUdajeDao.AddOrEdit(dto);

            result.IsOkOrThrow();

            return result.Id;
        }
        catch (Exception e)
        {
            Logger.Log(LogLevel.Error, "{}", e);
            throw new DatabaseException("Položku se nepodařilo přidat/upravit", e);
        }
    }

    public bool UzivatelExistuje(string prihlasovaciJmeno)
    {
        var result = UnitOfWork.Connection.ExecuteScalar<int>(
            "select count(*) from PRIHLASOVACI_UDAJE where JMENO = :prihlasovaciJmeno", new { prihlasovaciJmeno });

        return result != 0;
    }

    public void Delete(int id)
    {
        Delete(_prihlasovaciUdajeDao, id);
    }

    public PrihlasovaciUdajeModel Get(int id)
    {
        return Get(_prihlasovaciUdajeDao, id, MapToModel);
    }

    public IEnumerable<PrihlasovaciUdajeModel> GetAll()
    {
        return GetAll(_prihlasovaciUdajeDao, MapToModel);
    }

    private PrihlasovaciUdajeModel MapToModel(PrihlasovaciUdaje dto)
    {
        return new PrihlasovaciUdajeModel
        {
            PrihlasovaciUdajeId = EncodeId(dto.PrihlasovaciUdajeId),
            Jmeno = dto.Jmeno,
            Heslo = dto.Heslo
        };
    }

    private PrihlasovaciUdaje MapToDto(PrihlasovaciUdajeModel model)
    {
        return new PrihlasovaciUdaje
        {
            PrihlasovaciUdajeId = DecodeId(model.PrihlasovaciUdajeId),
            Jmeno = model.Jmeno,
            Heslo = model.Heslo
        };
    }
}