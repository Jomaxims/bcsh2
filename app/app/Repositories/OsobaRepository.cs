using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;

namespace app.Repositories;

public class OsobaRepository : BaseRepository
{
    private readonly GenericDao<Osoba> _osobaDao;

    public OsobaRepository(
        ILogger<OsobaRepository> logger,
        IDbUnitOfWork unitOfWork,
        IIdConverter idConverter,
        GenericDao<Osoba> osobaDao
    ) : base(logger, unitOfWork, idConverter)
    {
        _osobaDao = osobaDao;
    }

    public int AddOrEdit(OsobaModel model)
    {
        return AddOrEdit(_osobaDao, model, MapToDto);
    }

    public void Delete(int id)
    {
        Delete(_osobaDao, id);
    }

    public OsobaModel Get(int id)
    {
        return Get(_osobaDao, id, MapToModel);
    }

    public IEnumerable<OsobaModel> GetAll()
    {
        return GetAll(_osobaDao, MapToModel);
    }

    private OsobaModel MapToModel(Osoba dto)
    {
        return new OsobaModel
        {
            OsobaId = EncodeId(dto.OsobaId),
            Jmeno = dto.Jmeno,
            Prijmeni = dto.Prijmeni,
            DatumNarozeni = dto.DatumNarozeni
        };
    }

    private Osoba MapToDto(OsobaModel model)
    {
        return new Osoba
        {
            OsobaId = DecodeId(model.OsobaId),
            Jmeno = model.Jmeno,
            Prijmeni = model.Prijmeni,
            DatumNarozeni = model.DatumNarozeni
        };
    }
}