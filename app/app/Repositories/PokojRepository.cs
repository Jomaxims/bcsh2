using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;

namespace app.Repositories;

public class PokojRepository : BaseRepository
{
    private readonly GenericDao<Pokoj> _pokojDao;

    public PokojRepository(
        ILogger<PokojRepository> logger,
        IDbUnitOfWork unitOfWork,
        IIdConverter idConverter,
        GenericDao<Pokoj> pokojDao
    ) : base(logger, unitOfWork, idConverter)
    {
        _pokojDao = pokojDao;
    }

    public int AddOrEdit(PokojModel model)
    {
        return AddOrEdit(_pokojDao, model, MapToDto);
    }

    public void Delete(int id)
    {
        Delete(_pokojDao, id);
    }

    public PokojModel Get(int id)
    {
        return Get(_pokojDao, id, MapToModel);
    }

    public IEnumerable<PokojModel> GetAll()
    {
        return GetAll(_pokojDao, MapToModel);
    }

    private PokojModel MapToModel(Pokoj dto)
    {
        return new PokojModel
        {
            PokojId = EncodeId(dto.PokojId),
            Nazev = dto.Nazev,
            PocetMist = dto.PocetMist
        };
    }

    private Pokoj MapToDto(PokojModel model)
    {
        return new Pokoj
        {
            PokojId = DecodeId(model.PokojId),
            Nazev = model.Nazev,
            PocetMist = model.PocetMist
        };
    }
}