using app.DAL;
using app.Models.Sprava;
using app.Utils;

namespace app.Repositories;

/// <summary>
/// Repository pro práci s pojištěním
/// </summary>
public class PojisteniRepository : BaseRepository
{
    private readonly GenericDao<Pojisteni> _pojisteniDao;

    public PojisteniRepository(ILogger<PojisteniRepository> logger, IDbUnitOfWork unitOfWork, IIdConverter idConverter,
        GenericDao<Pojisteni> pojisteniDao) : base(logger, unitOfWork, idConverter)
    {
        _pojisteniDao = pojisteniDao;
    }

    /// <summary>
    /// Přidá nebo upraví (pokud má id) pojištění
    /// </summary>
    /// <param name="model">Pojištění</param>
    /// <returns>id pojištění</returns>
    public int AddOrEdit(PojisteniModel model)
    {
        return AddOrEdit(_pojisteniDao, model, MapToDto);
    }

    /// <summary>
    /// Smaže pojištění
    /// </summary>
    /// <param name="id">id pojištění</param>
    public void Delete(int id)
    {
        Delete(_pojisteniDao, id);
    }

    /// <summary>
    /// Získá pojištění
    /// </summary>
    /// <param name="id">pojištění id</param>
    /// <returns>Pojištění</returns>
    public PojisteniModel Get(int id)
    {
        return Get(_pojisteniDao, id, MapToModel);
    }

    /// <summary>
    /// Získá všechna pojištění
    /// </summary>
    /// <returns></returns>
    public IEnumerable<PojisteniModel> GetAll()
    {
        return GetAll(_pojisteniDao, MapToModel);
    }

    /// <summary>
    /// Mapovací funkce
    /// </summary>
    /// <param name="dto"></param>
    /// <returns></returns>
    private PojisteniModel MapToModel(Pojisteni dto)
    {
        return new PojisteniModel
        {
            PojisteniId = EncodeId(dto.PojisteniId),
            CenaZaDen = dto.CenaZaDen,
            Nazev = dto.Nazev
        };
    }

    /// <summary>
    /// Mapovací funkce
    /// </summary>
    /// <param name="model"></param>
    /// <returns></returns>
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