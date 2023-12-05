using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;

namespace app.Repositories;

/// <summary>
/// Repository pro práci s adresou
/// </summary>
public class AdresaRepository : BaseRepository
{
    private readonly GenericDao<Adresa> _adresaDao;

    public AdresaRepository(
        ILogger<AdresaRepository> logger,
        IDbUnitOfWork unitOfWork,
        IIdConverter idConverter,
        GenericDao<Adresa> adresaDao
    ) : base(logger, unitOfWork, idConverter)
    {
        _adresaDao = adresaDao;
    }

    /// <summary>
    /// Přidá nebo změní (pokud má id) adresu
    /// </summary>
    /// <param name="model">Adresa</param>
    /// <returns>id adresy</returns>
    public int AddOrEdit(AdresaModel model)
    {
        return AddOrEdit(_adresaDao, model, MapToDto);
    }

    /// <summary>
    /// Smaže adresu
    /// </summary>
    /// <param name="id">id adresy</param>
    public void Delete(int id)
    {
        Delete(_adresaDao, id);
    }

    /// <summary>
    /// Mapovací funkce
    /// </summary>
    /// <param name="model"></param>
    /// <returns></returns>
    private Adresa MapToDto(AdresaModel model)
    {
        return new Adresa
        {
            AdresaId = DecodeId(model.AdresaId),
            Mesto = model.Mesto,
            Psc = model.Psc,
            Ulice = model.Ulice,
            CisloPopisne = model.CisloPopisne,
            Poznamka = model.Poznamka,
            StatId = DecodeId(model.Stat?.StatId) ?? -1
        };
    }
}