using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;

namespace app.Repositories;

/// <summary>
/// Repository pro práci s kontaktem
/// </summary>
public class KontaktRepository : BaseRepository
{
    private readonly GenericDao<Kontakt> _kontaktDao;

    public KontaktRepository(
        ILogger<KontaktRepository> logger,
        IDbUnitOfWork unitOfWork,
        IIdConverter idConverter,
        GenericDao<Kontakt> kontaktDao
    ) : base(logger, unitOfWork, idConverter)
    {
        _kontaktDao = kontaktDao;
    }

    /// <summary>
    /// Přidá nebo změní (pokud má id) kontakt
    /// </summary>
    /// <param name="model">Kontakt</param>
    /// <returns>id kontaktu</returns>
    public int AddOrEdit(KontaktModel model)
    {
        return AddOrEdit(_kontaktDao, model, MapToDto);
    }

    /// <summary>
    /// Smaže kontakt
    /// </summary>
    /// <param name="id">id kontaktu</param>
    public void Delete(int id)
    {
        Delete(_kontaktDao, id);
    }

    /// <summary>
    /// Mapovací funkce
    /// </summary>
    /// <param name="model"></param>
    /// <returns></returns>
    private Kontakt MapToDto(KontaktModel model)
    {
        return new Kontakt
        {
            KontaktId = DecodeId(model.KontaktId),
            Email = model.Email,
            Telefon = model.Telefon
        };
    }
}