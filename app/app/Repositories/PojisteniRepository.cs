using app.DAL;
using app.Models.Sprava;
using app.Utils;

namespace app.Repositories;

public class PojisteniRepository : BaseRepository
{
    private readonly GenericDao<Pojisteni> _pojisteniDao;

    public PojisteniRepository(ILogger<PojisteniRepository> logger, IDbUnitOfWork unitOfWork, IIdConverter idConverter,
        GenericDao<Pojisteni> pojisteniDao) : base(logger, unitOfWork, idConverter)
    {
        _pojisteniDao = pojisteniDao;
    }

    public int AddOrEdit(PojisteniModel model) => AddOrEdit(_pojisteniDao, model, MapToDto);

    public void Delete(int id) => Delete(_pojisteniDao, id);

    public PojisteniModel Get(int id) => Get(_pojisteniDao, id, MapToModel);

    public IEnumerable<PojisteniModel> GetAll() => GetAll(_pojisteniDao, MapToModel);

    private PojisteniModel MapToModel(Pojisteni dto) => new()
    {
        PojisteniId = EncodeId(dto.PojisteniId),
        CenaZaDen = dto.CenaZaDen,
        Nazev = dto.Nazev
    };

    private Pojisteni MapToDto(PojisteniModel model) => new()
    {
        PojisteniId = DecodeId(model.PojisteniId),
        Nazev = model.Nazev,
        CenaZaDen = model.CenaZaDen
    };
}