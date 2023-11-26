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

    public int AddOrEdit(DopravaModel model) => AddOrEdit(_dopravaDao, model, MapToDto);

    public void Delete(int id) => Delete(_dopravaDao, id);

    public DopravaModel Get(int id) => Get(_dopravaDao, id, MapToModel);

    public IEnumerable<DopravaModel> GetAll() => GetAll(_dopravaDao, MapToModel);

    private DopravaModel MapToModel(Doprava dto) => new()
    {
        DopravaId = EncodeId(dto.DopravaId),
        Nazev = dto.Nazev
    };
    
    private Doprava MapToDto(DopravaModel model) => new()
    {
        DopravaId = DecodeId(model.DopravaId),
        Nazev = model.Nazev
    };
}