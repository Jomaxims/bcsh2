using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;
using Dapper;

namespace app.Repositories;

public class ZakaznikRepository : BaseRepository
{
    private readonly GenericDao<Zakaznik> _zakaznikDao;
    private readonly PrihlasovaciUdajeRepository _prihlasovaciUdajeRepository;
    private readonly OsobaRepository _osobaRepository;
    private readonly AdresaRepository _adresaRepository;
    private readonly KontaktRepository _kontaktRepository;
    private readonly StatRepository _statRepository;

    public ZakaznikRepository(
        ILogger<ZakaznikRepository> logger,
        IDbUnitOfWork unitOfWork,
        IIdConverter idConverter,
        GenericDao<Zakaznik> zakaznikDao,
        PrihlasovaciUdajeRepository prihlasovaciUdajeRepository,
        OsobaRepository osobaRepository,
        AdresaRepository adresaRepository,
        KontaktRepository kontaktRepository,
        StatRepository statRepository
    ) : base(logger, unitOfWork, idConverter)
    {
        _zakaznikDao = zakaznikDao;
        _prihlasovaciUdajeRepository = prihlasovaciUdajeRepository;
        _osobaRepository = osobaRepository;
        _adresaRepository = adresaRepository;
        _kontaktRepository = kontaktRepository;
        _statRepository = statRepository;
    }

    public int AddOrEdit(ZakaznikModel model)
    {
        UnitOfWork.BeginTransaction();

        try
        {
            // zákazník musí být vždy z ČR
            model.Adresa.Stat = new StatModel
            {
                StatId = EncodeId(_statRepository.GetCzId())
            };

            var prihlasovaciUdajeId = _prihlasovaciUdajeRepository.AddOrEdit(model.PrihlasovaciUdaje);
            var osobaId = _osobaRepository.AddOrEdit(model.Osoba);
            var kontaktId = _kontaktRepository.AddOrEdit(model.Kontakt);
            var adresaId = _adresaRepository.AddOrEdit(model.Adresa);

            var dto = MapToDto(model, prihlasovaciUdajeId, osobaId, kontaktId, adresaId);
            var result = _zakaznikDao.AddOrEdit(dto);

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

    public void Delete(int id) => Delete(_zakaznikDao, id);

    public ZakaznikModel Get(int id)
    {
        const string sql = """
                             select z.*, pu.*, k.*, a.*, o.OSOBA_ID, o.JMENO as osoba_jmeno, o.PRIJMENI, TO_CHAR(o.DATUM_NAROZENI, 'DD.MM.YYYY') as datum_narozeni from ZAKAZNIK z
                                 join PRIHLASOVACI_UDAJE pu on pu.PRIHLASOVACI_UDAJE_ID = z.PRIHLASOVACI_UDAJE_ID
                                 join KONTAKT k on k.KONTAKT_ID = z.KONTAKT_ID
                                 join ADRESA a on a.ADRESA_ID = z.ADRESA_ID
                                 join OSOBA o on o.OSOBA_ID = z.OSOBA_ID
                                 join STAT s on s.STAT_ID = a.STAT_ID
                                 where z.ZAKAZNIK_ID = :id
                           """;

        var row = UnitOfWork.Connection.QuerySingle<dynamic>(sql, new { id });
        var model = new ZakaznikModel
        {
            ZakaznikId = EncodeId((int)row.ZAKAZNIK_ID),
            PrihlasovaciUdaje = new PrihlasovaciUdajeModel
            {
                PrihlasovaciUdajeId = EncodeId((int)row.PRIHLASOVACI_UDAJE_ID),
                Jmeno = row.JMENO
            },
            Osoba = new OsobaModel
            {
                OsobaId = EncodeId((int)row.OSOBA_ID),
                Jmeno = row.OSOBA_JMENO,
                Prijmeni = row.PRIJMENI,
                DatumNarozeni = DateOnly.Parse(row.DATUM_NAROZENI)
            },
            Kontakt = new KontaktModel
            {
                KontaktId = EncodeId((int)row.KONTAKT_ID),
                Email = row.EMAIL,
                Telefon = row.TELEFON
            },
            Adresa = new AdresaModel
            {
                AdresaId = EncodeId((int)row.ADRESA_ID),
                Ulice = row.ULICE,
                CisloPopisne = row.CISLO_POPISNE,
                Mesto = row.MESTO,
                Psc = row.PSC,
                Poznamka = row.POZNAMKA,
                Stat = new StatModel
                {
                    StatId = EncodeId((int)row.STAT_ID),
                    Zkratka = row.ZKRATKA,
                    Nazev = row.STAT_NAZEV
                }
            }
        };

        return model;
    }

    public IEnumerable<ZakaznikModel> GetSpravaPreview(out int celkovyPocetRadku, string celeJmeno = "",
        string prihlasovaciJmeno = "", string email = "", string telefon = "", string adresa = "", int start = 0,
        int pocetRadku = 0)
    {
        var sql = $"""
                   select
                       ZAKAZNIK_ID,
                       JMENO ,
                       PRIJMENI ,
                       CELE_JMENO ,
                       PRIHLASOVACI_JMENO ,
                       EMAIL ,
                       TELEFON ,
                       ULICE ,
                       CISLO_POPISNE ,
                       MESTO ,
                       PSC ,
                       STAT_NAZEV ,
                       CELA_ADRESA,
                    count(*) over () as pocet_radku
                    FROM ZAKAZNIK_VIEW
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
        if (email != "")
            builder.Where("email = :email", new { email = $"%{email.ToLower()}%" });
        if (telefon != "")
            builder.Where("telefon = :telefon", new { telefon = $"%{telefon.ToLower()}%" });
        if (adresa != "")
            builder.Where("cela_adresa = :adresa", new { adresa = $"%{adresa.ToLower()}%" });

        var rows = UnitOfWork.Connection.Query<dynamic>(template.RawSql, template.Parameters);
        var model = rows.Select(row =>
        {
            var zakaznik = new ZakaznikModel
            {
                ZakaznikId = EncodeId((int)row.ZAKAZNIK_ID),
                PrihlasovaciUdaje = new PrihlasovaciUdajeModel
                {
                    Jmeno = row.PRIHLASOVACI_JMENO
                },
                Osoba = new OsobaModel
                {
                    Jmeno = row.JMENO,
                    Prijmeni = row.PRIJMENI
                },
                Kontakt = new KontaktModel
                {
                    Email = row.EMAIL,
                    Telefon = row.TELEFON
                },
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

            return zakaznik;
        });

        celkovyPocetRadku = Convert.ToInt32(rows.FirstOrDefault()?.POCET_RADKU ?? 0);
        return model;
    }

    private Zakaznik MapToDto(ZakaznikModel model, int prihlasovaciUdajeId, int osobaId, int kontaktId, int adresaId) =>
        new()
        {
            ZakaznikId = DecodeId(model.ZakaznikId),
            OsobaId = osobaId,
            PrihlasovaciUdajeId = prihlasovaciUdajeId,
            KontaktId = kontaktId,
            AdresaId = adresaId
        };

    private ZakaznikModel MapRowToModel(ZakaznikModel zakaznik, PrihlasovaciUdajeModel prihlasovaciUdaje,
        KontaktModel kontakt, AdresaModel adresa, OsobaModel osoba)
    {
        zakaznik.ZakaznikId = EncodeId(zakaznik.ZakaznikId);

        prihlasovaciUdaje.PrihlasovaciUdajeId = EncodeId(prihlasovaciUdaje.PrihlasovaciUdajeId);
        prihlasovaciUdaje.Heslo = null;
        zakaznik.PrihlasovaciUdaje = prihlasovaciUdaje;

        kontakt.KontaktId = EncodeId(kontakt.KontaktId);
        zakaznik.Kontakt = kontakt;

        adresa.AdresaId = EncodeId(adresa.AdresaId);
        zakaznik.Adresa = adresa;
        
        osoba.OsobaId = EncodeId(osoba.OsobaId);
        zakaznik.Osoba = osoba;

        return zakaznik;
    }
}