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

    public int AddOrEdit(OsobaModel model) => AddOrEdit(_osobaDao, model, MapToDto);

    public void Delete(int id) => Delete(_osobaDao, id);

    public OsobaModel Get(int id) => Get(_osobaDao, id, MapToModel);

    public IEnumerable<OsobaModel> GetAll() => GetAll(_osobaDao, MapToModel);

    private OsobaModel MapToModel(Osoba dto) => new()
    {
        OsobaId = EncodeId(dto.OsobaId),
        Jmeno = dto.Jmeno,
        Prijmeni = dto.Prijmeni,
        DatumNarozeni = dto.DatumNarozeni
    };
    
    private Osoba MapToDto(OsobaModel model) => new()
    {
        OsobaId = DecodeId(model.OsobaId),
        Jmeno = model.Jmeno,
        Prijmeni = model.Prijmeni,
        DatumNarozeni = model.DatumNarozeni
    };
}