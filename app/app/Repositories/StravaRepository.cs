using System.Transactions;
using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;
using Dapper;

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

    public int AddOrEdit(StravaModel model) => AddOrEdit(_stravaDao, model, MapToDto);

    public void Delete(int id) => Delete(_stravaDao, id);

    public StravaModel Get(int id) => Get(_stravaDao, id, MapToModel);

    public IEnumerable<StravaModel> GetAll() => GetAll(_stravaDao, MapToModel);

    private StravaModel MapToModel(Strava dto) => new()
    {
        StravaId = EncodeId(dto.StravaId),
        Nazev = dto.Nazev
    };
    
    private Strava MapToDto(StravaModel model) => new()
    {
        StravaId = DecodeId(model.StravaId),
        Nazev = model.Nazev
    };
}