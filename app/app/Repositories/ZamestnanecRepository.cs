using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;
using Dapper;

namespace app.Repositories;

public class ZamestnanecRepository : BaseRepository
{
    private readonly GenericDao<Zamestnanec> _zamestnanecDao;
    private readonly PrihlasovaciUdajeRepository _prihlasovaciUdajeRepository;

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

    public void Delete(int id) => Delete(_zamestnanecDao, id);

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
                Prijmeni = dto.Prijmeni,
            });

        return model;
    }

    public IEnumerable<ZamestnanecModel> GetSpravaPreview(out int celkovyPocetRadku, string celeJmeno = "",
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
            var zamestnanec = new ZamestnanecModel
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
                    Prijmeni = row.NADRIZENY_PRIJMENI,
                }
            };

            return zamestnanec;
        });

        celkovyPocetRadku = Convert.ToInt32(rows.FirstOrDefault()?.POCET_RADKU ?? 0);
        return model;
    }

    private Zamestnanec MapToDto(ZamestnanecModel model, int roleId, int prihlasovaciUdajeId, int? nadrizenyId = null) => new()
    {
        ZamestnanecId = DecodeId(model.ZamestnanecId),
        Jmeno = model.Jmeno,
        Prijmeni = model.Prijmeni,
        RoleId = roleId,
        NadrizenyId = nadrizenyId,
        PrihlasovaciUdajeId = prihlasovaciUdajeId
    };

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