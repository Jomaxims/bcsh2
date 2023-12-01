using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;

namespace app.Repositories;

/// <summary>
/// Repository pro práci s dopravou
/// </summary>
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

    /// <summary>
    /// Přidá nebo změní (pokud má id) dopravu
    /// </summary>
    /// <param name="model">Doprava</param>
    /// <returns>id dopravy</returns>
    public int AddOrEdit(DopravaModel model)
    {
        return AddOrEdit(_dopravaDao, model, MapToDto);
    }

    /// <summary>
    /// Smaže dopravu
    /// </summary>
    /// <param name="id">id dopravy</param>
    public void Delete(int id)
    {
        Delete(_dopravaDao, id);
    }

    /// <summary>
    /// Získá dopravu
    /// </summary>
    /// <param name="id">id dopravy</param>
    /// <returns>Doménový model dopravy</returns>
    public DopravaModel Get(int id)
    {
        return Get(_dopravaDao, id, MapToModel);
    }

    /// <summary>
    /// Získá všechny dopravy
    /// </summary>
    /// <returns>Doménové modely dopravy</returns>
    public IEnumerable<DopravaModel> GetAll()
    {
        return GetAll(_dopravaDao, MapToModel);
    }

    /// <summary>
    /// Mapovací funkce
    /// </summary>
    /// <param name="dto"></param>
    /// <returns></returns>
    private DopravaModel MapToModel(Doprava dto)
    {
        return new DopravaModel
        {
            DopravaId = EncodeId(dto.DopravaId),
            Nazev = dto.Nazev
        };
    }

    /// <summary>
    /// Mapovací funkce
    /// </summary>
    /// <param name="model"></param>
    /// <returns></returns>
    private Doprava MapToDto(DopravaModel model)
    {
        return new Doprava
        {
            DopravaId = DecodeId(model.DopravaId),
            Nazev = model.Nazev
        };
    }
}