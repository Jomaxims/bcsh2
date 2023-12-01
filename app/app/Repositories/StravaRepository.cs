using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;

namespace app.Repositories;

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

    public int AddOrEdit(StravaModel model)
    {
        return AddOrEdit(_stravaDao, model, MapToDto);
    }

    public void Delete(int id)
    {
        Delete(_stravaDao, id);
    }

    public StravaModel Get(int id)
    {
        return Get(_stravaDao, id, MapToModel);
    }

    public IEnumerable<StravaModel> GetAll()
    {
        return GetAll(_stravaDao, MapToModel);
    }

    private StravaModel MapToModel(Strava dto)
    {
        return new StravaModel
        {
            StravaId = EncodeId(dto.StravaId),
            Nazev = dto.Nazev
        };
    }

    private Strava MapToDto(StravaModel model)
    {
        return new Strava
        {
            StravaId = DecodeId(model.StravaId),
            Nazev = model.Nazev
        };
    }
}