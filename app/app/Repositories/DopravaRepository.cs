using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;

namespace app.Repositories;

public class DopravaRepository : BaseRepository
{
    private readonly GenericDao<Doprava> _dopravaDao;

    public DopravaRepository(
        ILogger<DopravaRepository> logger,
        IDbUnitOfWork unitOfWork,
        IIdConverter idConverter,
        GenericDao<Doprava> dopravaDao
    ) : base(logger, unitOfWork, idConverter)
    {
        _dopravaDao = dopravaDao;
    }

    public int AddOrEdit(DopravaModel model)
    {
        return AddOrEdit(_dopravaDao, model, MapToDto);
    }

    public void Delete(int id)
    {
        Delete(_dopravaDao, id);
    }

    public DopravaModel Get(int id)
    {
        return Get(_dopravaDao, id, MapToModel);
    }

    public IEnumerable<DopravaModel> GetAll()
    {
        return GetAll(_dopravaDao, MapToModel);
    }

    private DopravaModel MapToModel(Doprava dto)
    {
        return new DopravaModel
        {
            DopravaId = EncodeId(dto.DopravaId),
            Nazev = dto.Nazev
        };
    }

    private Doprava MapToDto(DopravaModel model)
    {
        return new Doprava
        {
            DopravaId = DecodeId(model.DopravaId),
            Nazev = model.Nazev
        };
    }
}