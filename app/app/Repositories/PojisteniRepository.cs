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

    public int AddOrEdit(PojisteniModel model)
    {
        return AddOrEdit(_pojisteniDao, model, MapToDto);
    }

    public void Delete(int id)
    {
        Delete(_pojisteniDao, id);
    }

    public PojisteniModel Get(int id)
    {
        return Get(_pojisteniDao, id, MapToModel);
    }

    public IEnumerable<PojisteniModel> GetAll()
    {
        return GetAll(_pojisteniDao, MapToModel);
    }

    private PojisteniModel MapToModel(Pojisteni dto)
    {
        return new PojisteniModel
        {
            PojisteniId = EncodeId(dto.PojisteniId),
            CenaZaDen = dto.CenaZaDen,
            Nazev = dto.Nazev
        };
    }

    private Pojisteni MapToDto(PojisteniModel model)
    {
        return new Pojisteni
        {
            PojisteniId = DecodeId(model.PojisteniId),
            Nazev = model.Nazev,
            CenaZaDen = model.CenaZaDen
        };
    }
}