using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;
using Dapper;

namespace app.Repositories;

/// <summary>
/// Repository pro práci se zaměstnanci
/// </summary>
public class ZamestnanecRepository : BaseRepository
{
    private readonly PrihlasovaciUdajeRepository _prihlasovaciUdajeRepository;
    private readonly GenericDao<Zamestnanec> _zamestnanecDao;

    public ZamestnanecRepository(
        ILogger<ZamestnanecRepository> logger,
        IDbUnitOfWork unitOfWork,
        IIdConverter idConverter,
        GenericDao<Zamestnanec> zamestnanecDao,
        PrihlasovaciUdajeRepository prihlasovaciUdajeRepository
    ) : base(logger, unitOfWork, idConverter)
    {
        _zamestnanecDao = zamestnanecDao;
        _prihlasovaciUdajeRepository = prihlasovaciUdajeRepository;
    }

    /// <summary>
    /// Přidá nebo upraví (pokud má id) zaměstnance
    /// </summary>
    /// <param name="model">Zaměstnanec</param>
    /// <returns>id zaměstnance</returns>
    /// <exception cref="DatabaseException">Pokud nastala při vkládání chyba</exception>
    public int AddOrEdit(ZamestnanecModel model)
    {
        UnitOfWork.BeginTransaction();

        try
        {
            var prihlasovaciUdajeId = _prihlasovaciUdajeRepository.AddOrEdit(model.PrihlasovaciUdaje);
            var roleId = DecodeIdOrDefault(model.Role.RoleId);
            var nadrizenyId = DecodeId(model.Nadrizeny?.ZamestnanecId);

            var dto = MapToDto(model, roleId, prihlasovaciUdajeId, nadrizenyId);

            var result = _zamestnanecDao.AddOrEdit(dto);

            result.IsOkOrThrow();

            UnitOfWork.Commit();

            return result.Id;
        }
        catch (Exception e)
        {
            UnitOfWork.Rollback();

            Logger.Log(LogLevel.Error, "{}", e);
            throw new DatabaseException("Položku se nepodařilo přidat/upravit", e);
        }
    }

    /// <summary>
    /// Smaže zaměstnance
    /// </summary>
    /// <param name="id">id zaměstnance</param>
    public void Delete(int id)
    {
        Delete(_zamestnanecDao, id);
    }

    /// <summary>
    /// Získá zaměstnance
    /// </summary>
    /// <param name="id">id zaměstnance</param>
    /// <returns></returns>
    public ZamestnanecModel Get(int id)
    {
        const string sql = """
                             select z.*, r.*, pu.*, n.* from zamestnanec z
                                  join role r on r.role_id = z.role_id
                                  join PRIHLASOVACI_UDAJE pu on pu.PRIHLASOVACI_UDAJE_ID = z.PRIHLASOVACI_UDAJE_ID
                                  left join zamestnanec n on n.ZAMESTNANEC_ID = z.NADRIZENY_ID
                                  where z.ZAMESTNANEC_ID = :id
                           """;

        var model = UnitOfWork.Connection
            .Query<ZamestnanecModel, RoleModel, PrihlasovaciUdajeModel, ZamestnanecModel, ZamestnanecModel>(sql,
                MapRowToModel, new { id },
                splitOn: "role_id, prihlasovaci_udaje_id, zamestnanec_id").First();

        return model;
    }

    /// <summary>
    /// Získá možné nadřízené zaměstnance
    /// </summary>
    /// <param name="id">id zaměstnance</param>
    /// <returns></returns>
    public IEnumerable<ZamestnanecModel> GetMozniNadrizeni(int id)
    {
        const string sql = """
                            SELECT
                              ZAMESTNANEC_ID,
                              JMENO ,
                              PRIJMENI
                            FROM zamestnanec_view
                            where ZAMESTNANEC_ID <> :id
                           """;

        var model = UnitOfWork.Connection
            .Query<Zamestnanec>(sql, new { id })
            .Select(dto => new ZamestnanecModel
            {
                ZamestnanecId = EncodeId(dto.ZamestnanecId),
                Jmeno = dto.Jmeno,
                Prijmeni = dto.Prijmeni
            });

        return model;
    }

    /// <summary>
    /// Získá zaměstnance dle filtrů pro přehled ve správě
    /// </summary>
    /// <param name="celkovyPocetRadku">Celkový počet řádků</param>
    /// <param name="celeJmeno">Celé jméno</param>
    /// <param name="prihlasovaciJmeno">Přihlašovací jméno</param>
    /// <param name="roleId">id role</param>
    /// <param name="nadrizenyJmeno">Jméno nadřízeného</param>
    /// <param name="start">První řádek stránkování</param>
    /// <param name="pocetRadku">Počet položek</param>
    /// <returns></returns>
    public IEnumerable<ZamestnanecPreviewModel> GetSpravaPreview(out int celkovyPocetRadku, string celeJmeno = "",
        string prihlasovaciJmeno = "", int roleId = 0, string nadrizenyJmeno = "", int start = 0, int pocetRadku = 0)
    {
        var sql = $"""
                   SELECT
                       ZAMESTNANEC_ID,
                       JMENO ,
                       PRIJMENI ,
                       CELE_JMENO ,
                       PRIHLASOVACI_JMENO ,
                       ROLE_NAZEV ,
                       ROLE_ID ,
                       NADRIZENY_JMENO ,
                       NADRIZENY_PRIJMENI ,
                       NADRIZENY_CELE_JMENO,
                       pck_utils.zamestnanci_podrizeny(zamestnanec_id) as podrizeni,
                       count(*) over () as pocet_radku
                    FROM zamestnanec_view
                   /**where**/
                   offset {start} rows fetch next {pocetRadku} rows only
                   """;
        var builder = new SqlBuilder();
        var template = builder.AddTemplate(sql);
        if (celeJmeno != "")
            builder.Where("LOWER(CELE_JMENO) like :celeJmeno", new { celeJmeno = $"%{celeJmeno.ToLower()}%" });
        if (prihlasovaciJmeno != "")
            builder.Where("LOWER(PRIHLASOVACI_JMENO) like :prihlasovaciJmeno",
                new { prihlasovaciJmeno = $"%{prihlasovaciJmeno.ToLower()}%" });
        if (roleId != 0)
            builder.Where("role_id = :roleId", new { roleId = roleId.ToString() });
        if (nadrizenyJmeno != "")
            builder.Where("nadrizeny_cele_jmeno = :nadrizeny", new { nadrizeny = $"%{nadrizenyJmeno.ToLower()}%" });

        var rows = UnitOfWork.Connection.Query<dynamic>(template.RawSql, template.Parameters);
        var model = rows.Select(row =>
        {
            var zamestnanec = new ZamestnanecPreviewModel
            {
                ZamestnanecId = EncodeId((int)row.ZAMESTNANEC_ID),
                PrihlasovaciUdaje = new PrihlasovaciUdajeModel
                {
                    Jmeno = row.PRIHLASOVACI_JMENO
                },
                Jmeno = row.JMENO,
                Prijmeni = row.PRIJMENI,
                Role = new RoleModel
                {
                    Nazev = row.ROLE_NAZEV
                },
                Nadrizeny = new ZamestnanecModel
                {
                    Jmeno = row.NADRIZENY_JMENO,
                    Prijmeni = row.NADRIZENY_PRIJMENI
                },
                Podrizeni = row.PODRIZENI ?? ""
            };

            return zamestnanec;
        });

        celkovyPocetRadku = Convert.ToInt32(rows.FirstOrDefault()?.POCET_RADKU ?? 0);
        return model;
    }

    /// <summary>
    /// Mapovací funkce
    /// </summary>
    /// <param name="model"></param>
    /// <param name="roleId"></param>
    /// <param name="prihlasovaciUdajeId"></param>
    /// <param name="nadrizenyId"></param>
    /// <returns></returns>
    private Zamestnanec MapToDto(ZamestnanecModel model, int roleId, int prihlasovaciUdajeId, int? nadrizenyId = null)
    {
        return new Zamestnanec
        {
            ZamestnanecId = DecodeId(model.ZamestnanecId),
            Jmeno = model.Jmeno,
            Prijmeni = model.Prijmeni,
            RoleId = roleId,
            NadrizenyId = nadrizenyId,
            PrihlasovaciUdajeId = prihlasovaciUdajeId
        };
    }

    /// <summary>
    /// Mapovací funkce
    /// </summary>
    /// <param name="zamestnanec"></param>
    /// <param name="role"></param>
    /// <param name="prihlasovaciUdaje"></param>
    /// <param name="nadrizeny"></param>
    /// <returns></returns>
    private ZamestnanecModel MapRowToModel(ZamestnanecModel zamestnanec, RoleModel role,
        PrihlasovaciUdajeModel prihlasovaciUdaje, ZamestnanecModel? nadrizeny)
    {
        zamestnanec.ZamestnanecId = EncodeId(zamestnanec.ZamestnanecId);

        role.RoleId = EncodeId(role.RoleId);
        zamestnanec.Role = role;

        prihlasovaciUdaje.PrihlasovaciUdajeId = EncodeId(prihlasovaciUdaje.PrihlasovaciUdajeId);
        prihlasovaciUdaje.Heslo = null;
        zamestnanec.PrihlasovaciUdaje = prihlasovaciUdaje;

        if (nadrizeny != null)
            nadrizeny.ZamestnanecId = EncodeId(nadrizeny.ZamestnanecId);
        zamestnanec.Nadrizeny = nadrizeny;

        return zamestnanec;
    }
}