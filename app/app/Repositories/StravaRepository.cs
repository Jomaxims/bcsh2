using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;

namespace app.Repositories;

/// <summary>
/// Repository pro práci se stavami
/// </summary>
public class StravaRepository : BaseRepository
{
    private readonly GenericDao<Strava> _stravaDao;

    public StravaRepository(
        ILogger<StravaRepository> logger,
        IDbUnitOfWork unitOfWork,
        IIdConverter idConverter,
        GenericDao<Strava> stravaDao
    ) : base(logger, unitOfWork, idConverter)
    {
        _stravaDao = stravaDao;
    }

    /// <summary>
    /// Přidá nebo upraví (pokud má id) stravu
    /// </summary>
    /// <param name="model">Strava</param>
    /// <returns>id stravy</returns>
    public int AddOrEdit(StravaModel model)
    {
        return AddOrEdit(_stravaDao, model, MapToDto);
    }

    /// <summary>
    /// Smaže stravu
    /// </summary>
    /// <param name="id">id stravy</param>
    public void Delete(int id)
    {
        Delete(_stravaDao, id);
    }

    /// <summary>
    /// Získá stravu
    /// </summary>
    /// <param name="id">id stravy</param>
    /// <returns></returns>
    public StravaModel Get(int id)
    {
        return Get(_stravaDao, id, MapToModel);
    }

    /// <summary>
    /// Získá všechny stravy
    /// </summary>
    /// <returns></returns>
    public IEnumerable<StravaModel> GetAll()
    {
        return GetAll(_stravaDao, MapToModel);
    }

    /// <summary>
    /// Mapovací funkce
    /// </summary>
    /// <param name="dto"></param>
    /// <returns></returns>
    private StravaModel MapToModel(Strava dto)
    {
        return new StravaModel
        {
            StravaId = EncodeId(dto.StravaId),
            Nazev = dto.Nazev
        };
    }

    /// <summary>
    /// Mapovací funkce
    /// </summary>
    /// <param name="model"></param>
    /// <returns></returns>
    private Strava MapToDto(StravaModel model)
    {
        return new Strava
        {
            StravaId = DecodeId(model.StravaId),
            Nazev = model.Nazev
        };
    }
}