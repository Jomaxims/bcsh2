using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;

namespace app.Repositories;

public class KontaktRepository : BaseRepository
{
    private readonly GenericDao<Kontakt> _kontaktDao;

    public KontaktRepository(
        ILogger<KontaktRepository> logger,
        IDbUnitOfWork unitOfWork,
        IIdConverter idConverter,
        GenericDao<Kontakt> kontaktDao
    ) : base(logger, unitOfWork, idConverter)
    {
        _kontaktDao = kontaktDao;
    }

    public int AddOrEdit(KontaktModel model)
    {
        return AddOrEdit(_kontaktDao, model, MapToDto);
    }

    public void Delete(int id)
    {
        Delete(_kontaktDao, id);
    }

    public KontaktModel Get(int id)
    {
        return Get(_kontaktDao, id, MapToModel);
    }

    public IEnumerable<KontaktModel> GetAll()
    {
        return GetAll(_kontaktDao, MapToModel);
    }

    private KontaktModel MapToModel(Kontakt dto)
    {
        return new KontaktModel
        {
            KontaktId = EncodeId(dto.KontaktId),
            Email = dto.Email,
            Telefon = dto.Telefon
        };
    }

    private Kontakt MapToDto(KontaktModel model)
    {
        return new Kontakt
        {
            KontaktId = DecodeId(model.KontaktId),
            Email = model.Email,
            Telefon = model.Telefon
        };
    }
}