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

    public int AddOrEdit(PokojModel model) => AddOrEdit(_pokojDao, model, MapToDto);

    public void Delete(int id) => Delete(_pokojDao, id);

    public PokojModel Get(int id) => Get(_pokojDao, id, MapToModel);

    public IEnumerable<PokojModel> GetAll() => GetAll(_pokojDao, MapToModel);

    private PokojModel MapToModel(Pokoj dto) => new()
    {
        PokojId = EncodeId(dto.PokojId),
        Nazev = dto.Nazev,
        PocetMist = dto.PocetMist
    };
    
    private Pokoj MapToDto(PokojModel model) => new()
    {
        PokojId = DecodeId(model.PokojId),
        Nazev = model.Nazev,
        PocetMist = model.PocetMist
    };
}