using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;

namespace app.Repositories;

/// <summary>
/// Repository pro práci s osobami
/// </summary>
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

    /// <summary>
    /// Přidá nebo upraví (pokud má id) osobu
    /// </summary>
    /// <param name="model">Osoba</param>
    /// <returns>id osoby</returns>
    public int AddOrEdit(OsobaModel model)
    {
        return AddOrEdit(_osobaDao, model, MapToDto);
    }

    /// <summary>
    /// Smaže osobu
    /// </summary>
    /// <param name="id">id osoby</param>
    public void Delete(int id)
    {
        Delete(_osobaDao, id);
    }

    /// <summary>
    /// Získá osobu
    /// </summary>
    /// <param name="id">id osoby</param>
    /// <returns>Osoby</returns>
    public OsobaModel Get(int id)
    {
        return Get(_osobaDao, id, MapToModel);
    }

    /// <summary>
    /// Mapovací funkce
    /// </summary>
    /// <param name="dto"></param>
    /// <returns></returns>
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

    /// <summary>
    /// Mapovací funkce
    /// </summary>
    /// <param name="model"></param>
    /// <returns></returns>
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