using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;
using Dapper;

namespace app.Repositories;

/// <summary>
/// Repository pro práci s přihlašovacími údaji
/// </summary>
public class PrihlasovaciUdajeRepository : BaseRepository
{
    private readonly GenericDao<PrihlasovaciUdaje> _prihlasovaciUdajeDao;

    public PrihlasovaciUdajeRepository(
        ILogger<PrihlasovaciUdajeRepository> logger,
        IDbUnitOfWork unitOfWork,
        IIdConverter idConverter,
        GenericDao<PrihlasovaciUdaje> prihlasovaciUdajeDao
    ) : base(logger, unitOfWork, idConverter)
    {
        _prihlasovaciUdajeDao = prihlasovaciUdajeDao;
    }

    /// <summary>
    /// Přidá nebo upraví (pokud má id) přihlašovací údaje
    /// </summary>
    /// <param name="model">Přihlašovací údaje</param>
    /// <returns>id přihlašovacích údajů</returns>
    /// <exception cref="DatabaseException">Pokud nastala při přidání chyba</exception>
    public int AddOrEdit(PrihlasovaciUdajeModel model)
    {
        try
        {
            var dto = MapToDto(model);
            var result = _prihlasovaciUdajeDao.AddOrEdit(dto);

            result.IsOkOrThrow();

            return result.Id;
        }
        catch (Exception e)
        {
            Logger.Log(LogLevel.Error, "{}", e);
            throw new DatabaseException("Položku se nepodařilo přidat/upravit", e);
        }
    }

    /// <summary>
    /// Zda uživatel s daným přihlaščovacím jménem existuje
    /// </summary>
    /// <param name="prihlasovaciJmeno">Přihlašovací jméno</param>
    /// <returns></returns>
    public bool UzivatelExistuje(string prihlasovaciJmeno)
    {
        var result = UnitOfWork.Connection.ExecuteScalar<int>(
            "select count(*) from PRIHLASOVACI_UDAJE where JMENO = :prihlasovaciJmeno", new { prihlasovaciJmeno });

        return result != 0;
    }

    /// <summary>
    /// Smaže přihlašovací údaje
    /// </summary>
    /// <param name="id">id přihlašovacích údajů</param>
    public void Delete(int id)
    {
        Delete(_prihlasovaciUdajeDao, id);
    }

    /// <summary>
    /// Mapovací funkce
    /// </summary>
    /// <param name="model"></param>
    /// <returns></returns>
    private PrihlasovaciUdaje MapToDto(PrihlasovaciUdajeModel model)
    {
        return new PrihlasovaciUdaje
        {
            PrihlasovaciUdajeId = DecodeId(model.PrihlasovaciUdajeId),
            Jmeno = model.Jmeno,
            Heslo = model.Heslo
        };
    }
}