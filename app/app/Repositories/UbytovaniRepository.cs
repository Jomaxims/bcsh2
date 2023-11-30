using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;
using Dapper;

namespace app.Repositories;

public class UbytovaniRepository : BaseRepository
{
    private readonly GenericDao<Ubytovani> _ubytovaniDao;
    private readonly AdresaRepository _adresaRepository;
    private readonly ObrazekUbytovaniRepository _obrazekUbytovaniRepository;

    public UbytovaniRepository(
        ILogger<UbytovaniRepository> logger,
        IDbUnitOfWork unitOfWork,
        IIdConverter idConverter,
        GenericDao<Ubytovani> ubytovaniDao,
        AdresaRepository adresaRepository,
        ObrazekUbytovaniRepository obrazekUbytovaniRepository
    ) : base(logger, unitOfWork, idConverter)
    {
        _ubytovaniDao = ubytovaniDao;
        _adresaRepository = adresaRepository;
        _obrazekUbytovaniRepository = obrazekUbytovaniRepository;

        _obrazekUbytovaniRepository.TransactionsManaged = true;
    }

    public int AddOrEdit(UbytovaniModel model)
    {
        UnitOfWork.BeginTransaction();

        try
        {
            var adresaId = _adresaRepository.AddOrEdit(model.Adresa);

            var dto = MapToDto(model, adresaId);

            var result = _ubytovaniDao.AddOrEdit(dto);

            result.IsOkOrThrow();
            
            foreach (var obrazekUbytovani in model.ObrazkyUbytovani)
            {
                _obrazekUbytovaniRepository.AddOrEdit(obrazekUbytovani, result.Id);
            }

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

    public void Delete(int id) => Delete(_ubytovaniDao, id);

    public UbytovaniModel Get(int id)
    {
        const string sql = """
                           select u.*, a.*, s.*, ou.* from ubytovani u
                                join adresa a on a.adresa_id = u.adresa_id
                                join stat s on a.stat_id = s.stat_id
                                left join obrazky_ubytovani ou on ou.ubytovani_id = u.ubytovani_id
                                where u.ubytovani_id = :id
                                order by ou.OBRAZKY_UBYTOVANI_ID
                           """;

        var obrazkyUbytovani = new List<ObrazkyUbytovaniModel>();
        var model = UnitOfWork.Connection
            .Query<UbytovaniModel, AdresaModel, StatModel, ObrazkyUbytovaniModel?, UbytovaniModel>(sql,
                (UbytovaniModel ubytovani, AdresaModel adresa, StatModel stat,
                    ObrazkyUbytovaniModel? obrazekUbytovani) =>
        {
            ubytovani.UbytovaniId = EncodeId(ubytovani.UbytovaniId);

            adresa.AdresaId = EncodeId(adresa.AdresaId);
            ubytovani.Adresa = adresa;

            stat.StatId = EncodeId(stat.StatId);
            ubytovani.Adresa.Stat = stat;

            if (obrazekUbytovani != null)
            {
                obrazkyUbytovani.Add(new ObrazkyUbytovaniModel
                {
                    ObrazkyUbytovaniId = EncodeId(obrazekUbytovani.ObrazkyUbytovaniId),
                    Nazev = obrazekUbytovani.Nazev
                });
            }

            return ubytovani;
        }, new { id },
                splitOn: "adresa_id,stat_id,obrazky_ubytovani_id").First();

        model.ObrazkyUbytovani = obrazkyUbytovani.ToArray();
        
        return model;
    }

    public IEnumerable<UbytovaniModel> GetSpravaPreview(out int celkovyPocetRadku, string nazev = "",
        int? pocetHvezd = null, string adresa = "", int start = 0, int pocetRadku = 0)
    {
        var sql = $"""
                   select
                       UBYTOVANI_ID ,
                       NAZEV ,
                       POCET_HVEZD ,
                       POPIS ,
                       ULICE ,
                       CISLO_POPISNE ,
                       MESTO ,
                       PSC ,
                       STAT_NAZEV ,
                       CELA_ADRESA,
                       count(*) over () as pocet_radku
                    FROM UBYTOVANI_VIEW
                   /**where**/
                   offset {start} rows fetch next {pocetRadku} rows only
                   """;
        var builder = new SqlBuilder();
        var template = builder.AddTemplate(sql);
        if (nazev != "")
            builder.Where("LOWER(nazev) like :nazev", new { nazev = $"%{nazev.ToLower()}%" });
        if (pocetHvezd != null)
            builder.Where("pocet_hvezd like :pocetHvezd",
                new { pocetHvezd });
        if (adresa != "")
            builder.Where("LOWER(cela_adresa) like :adresa", new { adresa = $"%{adresa.ToLower()}%" });

        var rows = UnitOfWork.Connection.Query<dynamic>(template.RawSql, template.Parameters);
        var model = rows.Select(row =>
        {
            var ubytovani = new UbytovaniModel
            {
                UbytovaniId = EncodeId((int)row.UBYTOVANI_ID),
                Nazev = row.NAZEV,
                Popis = row.POPIS,
                PocetHvezd = (int)row.POCET_HVEZD,
                Adresa = new AdresaModel
                {
                    Ulice = row.ULICE,
                    CisloPopisne = row.CISLO_POPISNE,
                    Mesto = row.MESTO,
                    Psc = row.PSC,
                    Stat = new StatModel
                    {
                        Nazev = row.STAT_NAZEV
                    }
                },
            };

            return ubytovani;
        });

        celkovyPocetRadku = Convert.ToInt32(rows.FirstOrDefault()?.POCET_RADKU ?? 0);
        return model;
    }

    private Ubytovani MapToDto(UbytovaniModel model, int adresaId) => new()
    {
        UbytovaniId = DecodeId(model.UbytovaniId),
        Nazev = model.Nazev,
        Popis = model.Popis,
        PocetHvezd = model.PocetHvezd,
        AdresaId = adresaId
    };
}