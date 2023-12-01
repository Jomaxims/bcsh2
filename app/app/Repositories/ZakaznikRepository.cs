using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;
using Dapper;

namespace app.Repositories;

/// <summary>
/// Repository pro práci se ubytování
/// </summary>
public class ZakaznikRepository : BaseRepository
{
    private readonly AdresaRepository _adresaRepository;
    private readonly KontaktRepository _kontaktRepository;
    private readonly ObjednavkaRepository _objednavkaRepository;
    private readonly OsobaRepository _osobaRepository;
    private readonly GenericDao<PrihlasovaciUdaje> _prihlasovaciUdajeDao;
    private readonly PrihlasovaciUdajeRepository _prihlasovaciUdajeRepository;
    private readonly StatRepository _statRepository;
    private readonly GenericDao<Zakaznik> _zakaznikDao;

    public ZakaznikRepository(
        ILogger<ZakaznikRepository> logger,
        IDbUnitOfWork unitOfWork,
        IIdConverter idConverter,
        GenericDao<Zakaznik> zakaznikDao,
        GenericDao<PrihlasovaciUdaje> prihlasovaciUdajeDao,
        PrihlasovaciUdajeRepository prihlasovaciUdajeRepository,
        OsobaRepository osobaRepository,
        AdresaRepository adresaRepository,
        KontaktRepository kontaktRepository,
        StatRepository statRepository,
        ObjednavkaRepository objednavkaRepository
    ) : base(logger, unitOfWork, idConverter)
    {
        _zakaznikDao = zakaznikDao;
        _prihlasovaciUdajeDao = prihlasovaciUdajeDao;
        _prihlasovaciUdajeRepository = prihlasovaciUdajeRepository;
        _osobaRepository = osobaRepository;
        _adresaRepository = adresaRepository;
        _kontaktRepository = kontaktRepository;
        _statRepository = statRepository;
        _objednavkaRepository = objednavkaRepository;
    }

    /// <summary>
    /// Přidá nebo upraví (pokud má id) zákazníka
    /// </summary>
    /// <param name="model">Zákazník</param>
    /// <returns>id zákazníka</returns>
    /// <exception cref="DatabaseException">Pokud nastala při vkládání chyba</exception>
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

    /// <summary>
    /// Změní heslo zákazníka
    /// </summary>
    /// <param name="zakaznikId">id zákazníka</param>
    /// <param name="heslo">Nové heslo</param>
    public void ZmenHesloZakaznika(int zakaznikId, string heslo)
    {
        var prihlasovaciUdajeId = UnitOfWork.Connection.QuerySingle<int>(
            "select pu.prihlasovaci_udaje_id from PRIHLASOVACI_UDAJE pu join zakaznik z on z.PRIHLASOVACI_UDAJE_ID = pu.prihlasovaci_udaje_id where z.ZAKAZNIK_ID = :zakaznikId",
            new { zakaznikId });

        _prihlasovaciUdajeDao.AddOrEdit(new PrihlasovaciUdaje
        {
            PrihlasovaciUdajeId = prihlasovaciUdajeId,
            Heslo = heslo,
            Jmeno = null
        }).IsOkOrThrow();
    }

    /// <summary>
    /// Smaže zákazníka a veškerá data s ním související (adresa, kontakt, osoba, objednávky, přihlašovací údaje)
    /// </summary>
    /// <param name="id">id zákazníka</param>
    /// <exception cref="DatabaseException">Pokud nastala při mazání chyba</exception>
    public void Delete(int id)
    {
        UnitOfWork.BeginTransaction();

        try
        {
            var zakaznik = Get(id);
            var objednavky = _objednavkaRepository.GetObjednavkyZakaznika(id);

            foreach (var objednavka in objednavky)
                _objednavkaRepository.Delete(DecodeIdOrDefault(objednavka.ObjednavkaId));

            Delete(_zakaznikDao, id);

            _prihlasovaciUdajeRepository.Delete(DecodeIdOrDefault(zakaznik.PrihlasovaciUdaje.PrihlasovaciUdajeId));
            _osobaRepository.Delete(DecodeIdOrDefault(zakaznik.Osoba.OsobaId));
            _adresaRepository.Delete(DecodeIdOrDefault(zakaznik.Adresa.AdresaId));
            _kontaktRepository.Delete(DecodeIdOrDefault(zakaznik.Kontakt.KontaktId));

            UnitOfWork.Commit();
        }
        catch (Exception e)
        {
            UnitOfWork.Rollback();

            Logger.Log(LogLevel.Error, "{}", e);
            throw new DatabaseException("Položku se nepodařilo smazat", e);
        }
    }

    /// <summary>
    /// Získá zákazníka
    /// </summary>
    /// <param name="id">id zákazníka</param>
    /// <returns></returns>
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

    /// <summary>
    /// Získá zákazníky dle filtrů pro přehled ve správě
    /// </summary>
    /// <param name="celkovyPocetRadku">Celkový počet řádků</param>
    /// <param name="celeJmeno">Celé jméno</param>
    /// <param name="prihlasovaciJmeno">Přihlašovací jméno</param>
    /// <param name="email">Email</param>
    /// <param name="telefon">Telefon</param>
    /// <param name="adresa">Adresa</param>
    /// <param name="start">První řádek stránkování</param>
    /// <param name="pocetRadku">Počet položek</param>
    /// <returns></returns>
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

    /// <summary>
    /// Mapovací funkce
    /// </summary>
    /// <param name="model"></param>
    /// <param name="prihlasovaciUdajeId"></param>
    /// <param name="osobaId"></param>
    /// <param name="kontaktId"></param>
    /// <param name="adresaId"></param>
    /// <returns></returns>
    private Zakaznik MapToDto(ZakaznikModel model, int prihlasovaciUdajeId, int osobaId, int kontaktId, int adresaId)
    {
        return new Zakaznik
        {
            ZakaznikId = DecodeId(model.ZakaznikId),
            OsobaId = osobaId,
            PrihlasovaciUdajeId = prihlasovaciUdajeId,
            KontaktId = kontaktId,
            AdresaId = adresaId
        };
    }
}