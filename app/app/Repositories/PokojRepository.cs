using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;

namespace app.Repositories;

/// <summary>
/// Repository pro práci s pokoji
/// </summary>
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

    /// <summary>
    /// Přidá nebo upraví (pokud má id) pokoj
    /// </summary>
    /// <param name="model">Pokoj</param>
    /// <returns>id pokoje</returns>
    /// <exception cref="DatabaseException">Pokud nastala při přidání chyba</exception>
    public int AddOrEdit(PokojModel model)
    {
        return AddOrEdit(_pokojDao, model, MapToDto);
    }

    /// <summary>
    /// Smaže pokoj
    /// </summary>
    /// <param name="id">id pokoje</param>
    public void Delete(int id)
    {
        Delete(_pokojDao, id);
    }

    /// <summary>
    /// Získá pokoj
    /// </summary>
    /// <param name="id">id pokoje</param>
    /// <returns></returns>
    public PokojModel Get(int id)
    {
        return Get(_pokojDao, id, MapToModel);
    }

    /// <summary>
    /// Získá všechny pokoje
    /// </summary>
    /// <returns></returns>
    public IEnumerable<PokojModel> GetAll()
    {
        return GetAll(_pokojDao, MapToModel);
    }

    /// <summary>
    /// Mapovací funkce
    /// </summary>
    /// <param name="dto"></param>
    /// <returns></returns>
    private PokojModel MapToModel(Pokoj dto)
    {
        return new PokojModel
        {
            PokojId = EncodeId(dto.PokojId),
            Nazev = dto.Nazev,
            PocetMist = dto.PocetMist
        };
    }

    /// <summary>
    /// Mapovací funkce
    /// </summary>
    /// <param name="model"></param>
    /// <returns></returns>
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