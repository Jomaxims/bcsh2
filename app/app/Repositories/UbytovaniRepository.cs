using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;
using Dapper;

namespace app.Repositories;

/// <summary>
/// Repository pro práci se ubytování
/// </summary>
public class UbytovaniRepository : BaseRepository
{
    private readonly AdresaRepository _adresaRepository;
    private readonly ObrazekUbytovaniRepository _obrazekUbytovaniRepository;
    private readonly GenericDao<Ubytovani> _ubytovaniDao;

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

    /// <summary>
    /// Přidá nebo upraví (pokud má id) ubytování
    /// </summary>
    /// <param name="model">Ubytování</param>
    /// <returns>id ubytování</returns>
    /// <exception cref="DatabaseException">Pokud nastala při vkládání chyba</exception>
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
                _obrazekUbytovaniRepository.AddOrEdit(obrazekUbytovani, result.Id);

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
    /// Smaže ubytování a veškerá data s ním související (adresa, obrázky)
    /// </summary>
    /// <param name="id">id ubytování</param>
    /// <exception cref="DatabaseException">Pokud nastala při mazání chyba</exception>
    public void Delete(int id)
    {
        UnitOfWork.BeginTransaction();

        try
        {
            var obrazkyUbytovaniIds = _obrazekUbytovaniRepository.GetObrazkyUbytovaniIdsByUbytovani(id);
            var adresaId = DecodeId(Get(id).Adresa.AdresaId)!.Value;

            foreach (var obrazkyUbytovaniId in obrazkyUbytovaniIds)
                _obrazekUbytovaniRepository.Delete(obrazkyUbytovaniId);

            Delete(_ubytovaniDao, id);

            _adresaRepository.Delete(adresaId);
            
            UnitOfWork.Commit();
        }
        catch (Exception e)
        {
            UnitOfWork.Rollback();

            Logger.Log(LogLevel.Error, "{}", e);
            throw new DatabaseException("Položku se nepodařilo přidat/upravit", e);
        }
    }

    /// <summary>
    /// Získá ubytování
    /// </summary>
    /// <param name="id">id ubytování</param>
    /// <returns></returns>
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
            .Query<UbytovaniModel, AdresaModel, StatModel, ObrazkyUbytovaniModel, UbytovaniModel>(sql,
                (ubytovani, adresa, stat, obrazekUbytovani) =>
                {
                    ubytovani.UbytovaniId = EncodeId(ubytovani.UbytovaniId);

                    adresa.AdresaId = EncodeId(adresa.AdresaId);
                    ubytovani.Adresa = adresa;

                    stat.StatId = EncodeId(stat.StatId);
                    ubytovani.Adresa.Stat = stat;

                    if (obrazekUbytovani != null)
                        obrazkyUbytovani.Add(new ObrazkyUbytovaniModel
                        {
                            ObrazkyUbytovaniId = EncodeId(obrazekUbytovani.ObrazkyUbytovaniId),
                            Nazev = obrazekUbytovani.Nazev
                        });

                    return ubytovani;
                }, new { id },
                splitOn: "adresa_id,stat_id,obrazky_ubytovani_id").First();

        model.ObrazkyUbytovani = obrazkyUbytovani.ToArray();

        return model;
    }

    /// <summary>
    /// Získá ubytování dle filtrů pro přehled ve správě
    /// </summary>
    /// <param name="celkovyPocetRadku">Celkový počet řádků</param>
    /// <param name="nazev">Název ubytování</param>
    /// <param name="pocetHvezd">Počet hvězd ubytování</param>
    /// <param name="adresa">Adresa ubytování</param>
    /// <param name="start">První řádek stránkování</param>
    /// <param name="pocetRadku">Počet položek</param>
    /// <returns></returns>
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
                }
            };

            return ubytovani;
        });

        celkovyPocetRadku = Convert.ToInt32(rows.FirstOrDefault()?.POCET_RADKU ?? 0);
        return model;
    }

    /// <summary>
    /// Mapovací funkce
    /// </summary>
    /// <param name="model"></param>
    /// <param name="adresaId"></param>
    /// <returns></returns>
    private Ubytovani MapToDto(UbytovaniModel model, int adresaId)
    {
        return new Ubytovani
        {
            UbytovaniId = DecodeId(model.UbytovaniId),
            Nazev = model.Nazev,
            Popis = model.Popis,
            PocetHvezd = model.PocetHvezd,
            AdresaId = adresaId
        };
    }
}