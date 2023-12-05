using System.Data;
using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;
using Dapper;
using Dapper.Oracle;

namespace app.Repositories;

/// <summary>
/// Repository pro práci s objednávkami
/// </summary>
public class ObjednavkaRepository : BaseRepository
{
    private readonly GenericDao<Objednavka> _objednavkaDao;
    private readonly GenericDao<Osoba> _osobaDao;

    private readonly ISet<OsobaModel> _osoby = new HashSet<OsobaModel>();
    private readonly GenericDao<Platba> _platbaDao;

    public ObjednavkaRepository(
        ILogger<ObjednavkaRepository> logger,
        IDbUnitOfWork unitOfWork,
        IIdConverter idConverter,
        GenericDao<Objednavka> objednavkaDao,
        GenericDao<Platba> platbaDao,
        GenericDao<Osoba> osobaDao
    ) : base(logger, unitOfWork, idConverter)
    {
        _objednavkaDao = objednavkaDao;
        _platbaDao = platbaDao;
        _osobaDao = osobaDao;
    }
    
    /// <summary>
    /// Zda repository spravuje vlastní transakce
    /// </summary>
    public bool TransactionsManaged { get; set; } = false;

    /// <summary>
    /// Získá id osob pro danou objednávku.
    /// </summary>
    /// <param name="objednavkaId">id objednávky</param>
    /// <returns>id osob</returns>
    private IEnumerable<int> GetOsobaObjednavkaIds(int objednavkaId)
    {
        return UnitOfWork.Connection.Query<int>(
            "select osoba_id from OSOBA_OBJEDNAVKA where OBJEDNAVKA_ID = :objednavkaId", new { objednavkaId });
    }

    /// <summary>
    /// Přidá osobu do bjednávky
    /// </summary>
    /// <param name="osobaId">id osoby</param>
    /// <param name="objednavkaId">id objednávky</param>
    private void AddOsobaObjednavka(int osobaId, int objednavkaId)
    {
        const string tableName = "osoba_objednavka";
        var parameters = new DynamicParameters();
        parameters.Add($"{Constants.DbProcedureParamPrefix}objednavka_id", objednavkaId);
        parameters.Add($"{Constants.DbProcedureParamPrefix}osoba_id", osobaId);
        parameters.AddResult();

        UnitOfWork.Connection.Query($"pck_{tableName}.manage_{tableName}", parameters,
            commandType: CommandType.StoredProcedure);

        parameters.GetResult().IsOkOrThrow();
    }

    /// <summary>
    /// Smaže osobu z objednávky
    /// </summary>
    /// <param name="osobaId"id osoby></param>
    /// <param name="objednavkaId">id objednávky</param>
    private void DeleteOsobaObjednavka(int osobaId, int objednavkaId)
    {
        const string tableName = "osoba_objednavka";
        var parameters = new DynamicParameters();
        parameters.Add($"{Constants.DbProcedureParamPrefix}objednavka_id", objednavkaId);
        parameters.Add($"{Constants.DbProcedureParamPrefix}osoba_id", osobaId);
        parameters.AddResult();

        UnitOfWork.Connection.Query($"pck_{tableName}.delete_{tableName}", parameters,
            commandType: CommandType.StoredProcedure);

        parameters.GetResult().IsOkOrThrow();
    }

    /// <summary>
    /// Zaplatí objednávku
    /// </summary>
    /// <param name="platbaId">id platby</param>
    /// <param name="cisloUctu">Číslo účtu</param>
    public void ZaplatObjednavku(int platbaId, string cisloUctu)
    {
        const string tableName = "platba";
        var parameters = new DynamicParameters();
        parameters.Add($"{Constants.DbProcedureParamPrefix}platba_id", platbaId);
        parameters.Add($"{Constants.DbProcedureParamPrefix}cislo_uctu", cisloUctu);
        parameters.AddResult();

        UnitOfWork.Connection.Query($"pck_{tableName}.zaplat_{tableName}", parameters,
            commandType: CommandType.StoredProcedure);

        parameters.GetResult().IsOkOrThrow();
    }

    /// <summary>
    /// Přidá nebo upraví (pokud má id) objednávku
    /// </summary>
    /// <param name="model">Objednávka</param>
    /// <returns>id objednávky</returns>
    /// <exception cref="DatabaseException">Pokud při vlkádání nastala chyba</exception>
    public int AddOrEdit(ObjednavkaModel model)
    {
        UnitOfWork.BeginTransaction();

        try
        {
            var dto = MapToDto(model);
            var result = _objednavkaDao.AddOrEdit(dto);
            result.IsOkOrThrow();

            var platbaDto = MapPlatbaToDto(model.Platba, result.Id);
            var platbaResult = _platbaDao.AddOrEdit(platbaDto);
            platbaResult.IsOkOrThrow();

            var oldOsobyIds = GetOsobaObjednavkaIds(result.Id).ToHashSet();

            foreach (var osoba in model.Osoby ?? Array.Empty<OsobaModel>())
            {
                var osobaResult = _osobaDao.AddOrEdit(new Osoba
                {
                    OsobaId = DecodeId(osoba.OsobaId),
                    Jmeno = osoba.Jmeno,
                    Prijmeni = osoba.Prijmeni,
                    DatumNarozeni = osoba.DatumNarozeni
                });

                osobaResult.IsOkOrThrow();

                if (oldOsobyIds.Contains(osobaResult.Id))
                    oldOsobyIds.Remove(osobaResult.Id);
                else
                    AddOsobaObjednavka(osobaResult.Id, result.Id);
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

    /// <summary>
    /// Smaže objednávku a veškerá data s ní související (osoby, platbu)
    /// </summary>
    /// <param name="id">id objednávky</param>
    /// <exception cref="DatabaseException">Pokud při odebírání nastala chyba</exception>
    public void Delete(int id)
    {
        if (!TransactionsManaged) UnitOfWork.BeginTransaction();

        try
        {
            var platbaId = DecodeIdOrDefault(Get(id).Platba.PlatbaId);
            var osobaIds = GetOsobaObjednavkaIds(id);

            foreach (var osobaId in osobaIds)
            {
                DeleteOsobaObjednavka(osobaId, id);
                _osobaDao.Delete(osobaId).IsOkOrThrow();
            }

            Delete(_platbaDao, platbaId);

            Delete(_objednavkaDao, id);

            if (!TransactionsManaged) UnitOfWork.Commit();
        }
        catch (Exception e)
        {
            if (!TransactionsManaged) UnitOfWork.Rollback();

            Logger.Log(LogLevel.Error, "{}", e);
            throw new DatabaseException("Položku se nepodařilo smazat", e);
        }
    }

    /// <summary>
    /// Získá objednávku
    /// </summary>
    /// <param name="id">id objednávky</param>
    /// <returns>Objednávka</returns>
    public ObjednavkaModel Get(int id)
    {
        const string sql = """
                             select
                               o.*,
                               p.*,
                               t.*,
                               po.*,
                               pok.*,
                               os.*
                           from objednavka o
                           join platba p on p.objednavka_id = o.objednavka_id
                           join termin t on t.termin_id = o.termin_id
                           join pojisteni po on po.pojisteni_id = o.pojisteni_id
                           join pokoj pok on pok.pokoj_id = o.pokoj_id
                           left join osoba_objednavka oo on oo.objednavka_id = o.objednavka_id
                           left join osoba os on os.osoba_id = oo.osoba_id
                           where o.objednavka_id = :id
                           """;

        _osoby.Clear();
        var model = UnitOfWork.Connection
            .Query<Objednavka, PlatbaModel, Termin, PojisteniModel, PokojModel, OsobaModel, ObjednavkaModel>(
                sql,
                MapRowToModel, new { id },
                splitOn: "platba_id, termin_id, pojisteni_id, pokoj_id, osoba_id").First();

        model.Osoby = _osoby.ToArray();

        return model;
    }

    /// <summary>
    /// Získá objednávky pro přehled ve správě
    /// </summary>
    /// <param name="celkovyPocetRadku">Celkový počet řádků</param>
    /// <param name="zakaznik">Jméno zákazníka</param>
    /// <param name="datumOd">Datum od</param>
    /// <param name="datumDo">Datum do</param>
    /// <param name="ubytovani">Název ubytování</param>
    /// <param name="castkaOd">Částka od</param>
    /// <param name="castkaDo">Částka do</param>
    /// <param name="zaplaceno">Zaplaceno</param>
    /// <param name="start">První řádek stránkování</param>
    /// <param name="pocetRadku">Počet položek</param>
    /// <returns></returns>
    public IEnumerable<ObjednavkaModel> GetSpravaPreview(out int celkovyPocetRadku, string zakaznik = "",
        DateOnly datumOd = default, DateOnly datumDo = default, string ubytovani = "", int? castkaOd = null,
        int? castkaDo = null, bool? zaplaceno = null, int start = 0,
        int pocetRadku = 0)
    {
        var sql = $"""
                   SELECT
                       OBJEDNAVKA_ID ,
                       OD ,
                       DO ,
                       UBYTOVANI_NAZEV ,
                       POKOJ_NAZEV ,
                       JMENO ,
                       PRIJMENI ,
                       CELE_JMENO ,
                       CASTKA ,
                       ZAPLACENA,
                       count(*) over () as pocet_radku
                    FROM objednavka_view
                   /**where**/
                   offset {start} rows fetch next {pocetRadku} rows only
                   """;
        var builder = new SqlBuilder();
        var template = builder.AddTemplate(sql);
        if (datumOd != default)
            builder.Where("od >= TO_DATE(:datumOd, 'YYYY-MM-DD')", new { datumOd = datumOd.ToString("o") });
        if (datumDo != default)
            builder.Where("do <= TO_DATE(:datumDo, 'YYYY-MM-DD')", new { datumDo = datumDo.ToString("o") });
        if (zakaznik != "")
            builder.Where("LOWER(CELE_JMENO) like :zakaznik", new { zakaznik = $"%{zakaznik.ToLower()}%" });
        if (ubytovani != "")
            builder.Where("LOWER(ubytovani_nazev) like :ubytovani", new { ubytovani = $"%{ubytovani.ToLower()}%" });
        if (castkaOd != null)
            builder.Where("castka >= :castkaOd", new { castkaOd = $"{castkaOd}" });
        if (castkaDo != null)
            builder.Where("castka <= :castkaDo", new { castkaDo = $"{castkaDo}" });
        if (zaplaceno != null)
            builder.Where("zaplacena = :zaplaceno", new { zaplaceno = $"{(zaplaceno.Value ? 1 : 0)}" });

        var rows = UnitOfWork.Connection.Query<dynamic>(template.RawSql, template.Parameters);
        var model = rows.Select(row =>
        {
            var objednavka = new ObjednavkaModel
            {
                ObjednavkaId = EncodeId((int)row.OBJEDNAVKA_ID),
                Termin = new TerminModel
                {
                    Od = DateOnly.FromDateTime(row.OD),
                    Do = DateOnly.FromDateTime(row.DO)
                },
                Zajezd = new ZajezdModel
                {
                    Ubytovani = new UbytovaniModel
                    {
                        Nazev = row.UBYTOVANI_NAZEV
                    }
                },
                Pokoj = new PokojModel
                {
                    Nazev = row.POKOJ_NAZEV
                },
                Zakaznik = new ZakaznikModel
                {
                    Osoba = new OsobaModel
                    {
                        Jmeno = row.JMENO,
                        Prijmeni = row.PRIJMENI
                    }
                },
                Platba = new PlatbaModel
                {
                    Castka = (double)row.CASTKA,
                    Zaplacena = (int)row.ZAPLACENA == 1
                }
            };

            return objednavka;
        });

        celkovyPocetRadku = Convert.ToInt32(rows.FirstOrDefault()?.POCET_RADKU ?? 0);
        return model;
    }

    /// <summary>
    /// Spočítá výslednou částku objednávky
    /// </summary>
    /// <param name="pojisteniId">id pojištění</param>
    /// <param name="terminId">id termínu</param>
    /// <param name="pocetOsob">Počet osob</param>
    /// <returns></returns>
    public double SpocitejCastkuObjednavky(int pojisteniId, int terminId, int pocetOsob)
    {
        var parameters = new OracleDynamicParameters();
        parameters.Add("p_pojisteni_id", pojisteniId);
        parameters.Add("p_termin_id", terminId);
        parameters.Add("p_pocet_osob", pocetOsob);
        parameters.Add("ret", 0, OracleMappingType.Decimal, ParameterDirection.ReturnValue);

        UnitOfWork.Connection.ExecuteScalar("pck_utils.calculate_castka", parameters);

        return parameters.Get<double>("ret");
    }

    /// <summary>
    /// Získá objednávky zákazníka
    /// </summary>
    /// <param name="zakaznikId">id zákazníka</param>
    /// <returns></returns>
    public IEnumerable<ObjednavkaModel> GetObjednavkyZakaznika(int zakaznikId)
    {
        var sql = """
                  SELECT
                      OBJEDNAVKA_ID ,
                      ZAKAZNIK_ID,
                      OD ,
                      DO ,
                      UBYTOVANI_NAZEV ,
                      POKOJ_NAZEV ,
                      JMENO ,
                      PRIJMENI ,
                      CELE_JMENO ,
                      CASTKA ,
                      ZAPLACENA
                   FROM objednavka_view
                   where ZAKAZNIK_ID = :zakaznikId
                  """;
        var builder = new SqlBuilder();
        var template = builder.AddTemplate(sql);

        var rows = UnitOfWork.Connection.Query<dynamic>(template.RawSql, new { zakaznikId });
        var model = rows.Select(row =>
        {
            var objednavka = new ObjednavkaModel
            {
                ObjednavkaId = EncodeId((int)row.OBJEDNAVKA_ID),
                Termin = new TerminModel
                {
                    Od = DateOnly.FromDateTime(row.OD),
                    Do = DateOnly.FromDateTime(row.DO)
                },
                Zajezd = new ZajezdModel
                {
                    Ubytovani = new UbytovaniModel
                    {
                        Nazev = row.UBYTOVANI_NAZEV
                    }
                },
                Pokoj = new PokojModel
                {
                    Nazev = row.POKOJ_NAZEV
                },
                Zakaznik = new ZakaznikModel
                {
                    Osoba = new OsobaModel
                    {
                        Jmeno = row.JMENO,
                        Prijmeni = row.PRIJMENI
                    }
                },
                Platba = new PlatbaModel
                {
                    Castka = (double)row.CASTKA,
                    Zaplacena = (int)row.ZAPLACENA == 1
                }
            };

            return objednavka;
        });

        return model;
    }

    /// <summary>
    /// Mapovací funkce
    /// </summary>
    /// <param name="model"></param>
    /// <returns></returns>
    private Objednavka MapToDto(ObjednavkaModel model)
    {
        return new Objednavka
        {
            ObjednavkaId = DecodeId(model.ObjednavkaId),
            PocetOsob = model.PocetOsob,
            PojisteniId = DecodeIdOrDefault(model.Pojisteni.PojisteniId),
            PokojId = DecodeIdOrDefault(model.Pokoj.PokojId),
            TerminId = DecodeIdOrDefault(model.Termin.TerminId),
            ZakaznikId = DecodeIdOrDefault(model.Zakaznik.ZakaznikId)
        };
    }

    /// <summary>
    /// Mapovací funkce
    /// </summary>
    /// <param name="model"></param>
    /// <param name="objednavkaId">id objednávky</param>
    /// <returns></returns>
    private Platba MapPlatbaToDto(PlatbaModel model, int objednavkaId)
    {
        return new Platba
        {
            Castka = model.Castka,
            CisloUctu = model.CisloUctu,
            ObjednavkaId = objednavkaId,
            Zaplacena = model.Zaplacena,
            PlatbaId = DecodeId(model.PlatbaId)
        };
    }

    /// <summary>
    /// Mapovací funkce
    /// </summary>
    /// <param name="objednavkaDto"></param>
    /// <param name="platba"></param>
    /// <param name="terminDto"></param>
    /// <param name="pojisteni"></param>
    /// <param name="pokoj"></param>
    /// <param name="osoba"></param>
    /// <returns></returns>
    private ObjednavkaModel MapRowToModel(Objednavka objednavkaDto, PlatbaModel platba, Termin terminDto,
        PojisteniModel pojisteni, PokojModel pokoj, OsobaModel osoba)
    {
        var objednavka = new ObjednavkaModel
        {
            ObjednavkaId = EncodeId(objednavkaDto.ObjednavkaId),
            Zajezd = new ZajezdModel
            {
                ZajezdId = EncodeId(terminDto.ZajezdId)
            },
            PocetOsob = objednavkaDto.PocetOsob
        };
        objednavka.Zakaznik = new ZakaznikModel
        {
            ZakaznikId = EncodeId(objednavkaDto.ZakaznikId)
        };

        platba.PlatbaId = EncodeId(platba.PlatbaId);
        objednavka.Platba = platba;

        var termin = new TerminModel
        {
            TerminId = EncodeId(terminDto.TerminId),
            Od = terminDto.Od,
            Do = terminDto.Do
        };
        objednavka.Termin = termin;

        pojisteni.PojisteniId = EncodeId(pojisteni.PojisteniId);
        objednavka.Pojisteni = pojisteni;

        pokoj.PokojId = EncodeId(pokoj.PokojId);
        objednavka.Pokoj = pokoj;

        if (osoba != null)
        {
            osoba.OsobaId = EncodeId(osoba.OsobaId);
            _osoby.Add(osoba);
        }

        return objednavka;
    }
}