﻿using System.Data;
using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;
using Dapper;

namespace app.Repositories;

public class ZajezdRepository : BaseRepository
{
    private readonly GenericDao<Zajezd> _zajezdDao;
    private readonly GenericDao<Termin> _terminDao;
    private readonly GenericDao<PokojeTerminu> _pokojeTerminuDao;

    public ZajezdRepository(
        ILogger<ZajezdRepository> logger,
        IDbUnitOfWork unitOfWork,
        IIdConverter idConverter,
        GenericDao<Zajezd> zajezdDao,
        GenericDao<Termin> terminDao,
        GenericDao<PokojeTerminu> pokojeTerminuDao
        ) : base(logger, unitOfWork, idConverter)
    {
        _zajezdDao = zajezdDao;
        _terminDao = terminDao;
        _pokojeTerminuDao = pokojeTerminuDao;
    }

    public int AddOrEdit(ZajezdModel model)
    {
        UnitOfWork.BeginTransaction();
    
        try
        {
            var dto = MapToDto(model);
    
            var result = _zajezdDao.AddOrEdit(dto);
    
            result.IsOkOrThrow();

            var oldTermins = GetTerminIds(result.Id).ToHashSet();
            var oldPokojeTerminu = new Dictionary<int, ISet<int>>();
            foreach (var termin in model.Terminy)
            {
                var terminResult = _terminDao.AddOrEdit(new Termin
                {
                    TerminId = DecodeId(termin.TerminId),
                    Od = termin.Od,
                    Do = termin.Do,
                    ZajezdId = result.Id
                });
                
                terminResult.IsOkOrThrow();
                oldTermins.Remove(terminResult.Id);
                
                oldPokojeTerminu.Add(terminResult.Id, GetPokojeTerminuIds(terminResult.Id).ToHashSet());

                foreach (var pokojTerminu in termin.PokojeTerminu ?? Array.Empty<PokojTerminu>())
                {
                    var pokojResult = AddOrEditPokojeTerminu(new PokojeTerminu
                    {
                        CelkovyPocetPokoju = pokojTerminu.CelkovyPocetPokoju,
                        PocetObsazenychPokoju = pokojTerminu.PocetObsazenychPokoju,
                        TerminyId = terminResult.Id,
                        PokojId = DecodeIdOrDefault(pokojTerminu.Pokoj.PokojId)
                    });

                    oldPokojeTerminu[terminResult.Id].Remove(pokojResult.pokoj_id);
                }

                foreach (var pokojId in oldPokojeTerminu[terminResult.Id])
                {
                    DeletePokojeTerminu(terminResult.Id, pokojId);
                }
            }

            foreach (var terminId in oldTermins)
            {
                foreach (var pokojId in GetPokojeTerminuIds(terminId))
                {
                    DeletePokojeTerminu(terminId, pokojId);
                }
                
                _terminDao.Delete(terminId).IsOkOrThrow();
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

    private IEnumerable<int> GetTerminIds(int zajezdId)
    {
        return UnitOfWork.Connection.Query<int>("select termin_id from TERMIN where ZAJEZD_ID = :zajezdId", new { zajezdId });
    }
    
    private IEnumerable<int> GetPokojeTerminuIds(int terminId)
    {
        return UnitOfWork.Connection.Query<int>("select pokoj_id from POKOJE_TERMINU where TERMIN_ID = :terminId", new { terminId });
    }

    private void DeletePokojeTerminu(int terminId, int pokojId)
    {
        const string tableName = "pokoje_terminu";
        var parameters = new DynamicParameters();
        parameters.Add($"{Constants.DbProcedureParamPrefix}termin_id", terminId);
        parameters.Add($"{Constants.DbProcedureParamPrefix}pokoj_id", pokojId);
        parameters.AddResult();

        UnitOfWork.Connection.Query($"pck_{tableName}.delete_{tableName}", parameters, commandType: CommandType.StoredProcedure);
        
        parameters.GetResult().IsOkOrThrow();
    }
    
    private (int termin_id, int pokoj_id) AddOrEditPokojeTerminu(PokojeTerminu dto)
    {
        const string tableName = "pokoje_terminu";
        
        var parameters = new DynamicParameters();
        parameters.Add($"{Constants.DbProcedureParamPrefix}termin_id", dto.TerminyId, direction: ParameterDirection.InputOutput);
        parameters.Add($"{Constants.DbProcedureParamPrefix}pokoj_id", dto.PokojId, direction: ParameterDirection.InputOutput);
        parameters.Add($"{Constants.DbProcedureParamPrefix}celkovy_pocet_pokoju", dto.CelkovyPocetPokoju, direction: ParameterDirection.InputOutput);
        parameters.Add($"{Constants.DbProcedureParamPrefix}pocet_obsazenych_pokoju", dto.PocetObsazenychPokoju, direction: ParameterDirection.InputOutput);
        parameters.AddResult();

        UnitOfWork.Connection.Query($"pck_{tableName}.manage_{tableName}", parameters, commandType: CommandType.StoredProcedure);

        var result = parameters.GetResult();
        result.IsOkOrThrow();
        
        return (parameters.Get<int>($"{Constants.DbProcedureParamPrefix}termin_id"), parameters.Get<int>($"{Constants.DbProcedureParamPrefix}pokoj_id"));
    }
    
    public void Delete(int id) => Delete(_zajezdDao, id);

    public ZajezdModel Get(int id)
    {
        const string sql = """
                           select
                               z.zajezd_id, z.popis, z.cena_za_osobu, z.sleva_procent, z.zobrazit,
                               s.strava_id, s.nazev as strava_nazev,
                               d.doprava_id, d.nazev as doprava_nazev,
                               u.ubytovani_id, u.nazev as ubytovani_nazev, u.popis as ubytovani_popis, u.pocet_hvezd,
                               ou.obrazky_ubytovani_id/**, ou.obrazek**/, ou.nazev as obrazky_ubytovani_nazev,
                               a.adresa_id, a.ulice, a.cislo_popisne, a.mesto, a.psc, a.poznamka,
                               sa.stat_id, sa.zkratka, sa.nazev as stat_nazev,
                               t.termin_id, t.od, t.do,
                               pt.celkovy_pocet_pokoju, pt.pocet_obsazenych_pokoju,
                               p.pokoj_id, p.pocet_mist, p.nazev as pokoj_nazev
                           from zajezd z
                           join strava s on s.strava_id = z.strava_id
                           join doprava d on d.doprava_id = z.doprava_id
                           join ubytovani u on u.ubytovani_id = z.ubytovani_id
                           left join obrazky_ubytovani ou on ou.ubytovani_id = u.ubytovani_id
                           join adresa a on a.adresa_id = u.adresa_id
                           join stat sa on sa.stat_id = a.stat_id
                           left join termin t on t.zajezd_id = z.zajezd_id
                           left join pokoje_terminu pt on pt.termin_id = t.termin_id
                           left join pokoj p on p.pokoj_id = pt.pokoj_id
                           where z.zajezd_id = :id
                           """;

        var obrazkyUbytovani = new Dictionary<decimal, ObrazkyUbytovaniModel>();
        var terminyZajezdu = new Dictionary<decimal, TerminModel>();
        var rows = UnitOfWork.Connection.Query<dynamic>(sql, new { id });
        
        foreach (var row in rows)
        {
            if (row.OBRAZKY_UBYTOVANI_ID != null)
            {
                obrazkyUbytovani.TryAdd(row.OBRAZKY_UBYTOVANI_ID, new ObrazkyUbytovaniModel
                {
                    ObrazkyUbytovaniId = EncodeId((int)row.OBRAZKY_UBYTOVANI_ID),
                    // Obrazek = row.OBRAZEK,
                    Nazev = row.OBRAZKY_UBYTOVANI_NAZEV
                });
            }

            if (row.TERMIN_ID != null)
            {
                terminyZajezdu.TryAdd(row.TERMIN_ID, new TerminModel
                {
                    TerminId = EncodeId((int)row.TERMIN_ID),
                    Od = DateOnly.FromDateTime(row.OD),
                    Do = DateOnly.FromDateTime(row.DO),
                    PokojeTerminu = new List<PokojTerminu>()
                });
            }

            terminyZajezdu.TryGetValue(row.TERMIN_ID ?? 0, out TerminModel termin);

            if (row.POKOJ_ID != null)
            {
                ((IList<PokojTerminu>)termin.PokojeTerminu).Add(new PokojTerminu
                {
                    CelkovyPocetPokoju = (int)row.CELKOVY_POCET_POKOJU,
                    PocetObsazenychPokoju = (int)row.POCET_OBSAZENYCH_POKOJU,
                    Pokoj = new PokojModel
                    {
                        PokojId = EncodeId((int)row.POKOJ_ID),
                        PocetMist = (int)row.POCET_MIST,
                        Nazev = row.POKOJ_NAZEV
                    }
                });
            }
        }
        
        var firstRow = rows.First();
        var model = new ZajezdModel
        {
            ZajezdId = EncodeId((int)firstRow.ZAJEZD_ID),
            Popis = firstRow.POPIS,
            CenaZaOsobu = (double)firstRow.CENA_ZA_OSOBU,
            SlevaProcent = (int?)firstRow.SLEVA_PROCENT,
            Zobrazit = firstRow.ZOBRAZIT != 0,
            Terminy = terminyZajezdu.Values,
            Ubytovani = new UbytovaniModel
            {
                UbytovaniId = EncodeId((int)firstRow.UBYTOVANI_ID),
                Nazev = firstRow.UBYTOVANI_NAZEV,
                Popis = firstRow.UBYTOVANI_POPIS,
                PocetHvezd = (int)firstRow.POCET_HVEZD,
                Adresa = new AdresaModel
                {
                    AdresaId = EncodeId((int)firstRow.ADRESA_ID),
                    Ulice = firstRow.ULICE,
                    CisloPopisne = firstRow.CISLO_POPISNE,
                    Mesto = firstRow.MESTO,
                    Psc = firstRow.PSC,
                    Poznamka = firstRow.POZNAMKA,
                    Stat = new StatModel
                    {
                        StatId = EncodeId((int)firstRow.STAT_ID),
                        Zkratka = firstRow.ZKRATKA,
                        Nazev = firstRow.STAT_NAZEV
                    }
                },
                ObrazkyUbytovani = obrazkyUbytovani.Values.ToArray()
            },
            Doprava = new DopravaModel
            {
                DopravaId = EncodeId((int)firstRow.DOPRAVA_ID),
                Nazev = firstRow.DOPRAVA_NAZEV
            },
            Strava = new StravaModel
            {
                StravaId = EncodeId((int)firstRow.STRAVA_ID),
                Nazev = firstRow.STRAVA_NAZEV
            }
        };
        
        return model;
    }

    public IEnumerable<ZajezdModel> GetSpravaPreview(out int celkovyPocetRadku, string ubytovani = "",
        string adresa = "", int? cenaOd = null, int? cenaDo = null, int? slevaOd = null, int? slevaDo = null,
        int? dopravaId = null, int? stravaId = null, int start = 0, int pocetRadku = 0)
    {
        var sql = $"""
                   select
                       ZAJEZD_ID ,
                       UBYTOVANI_NAZEV ,
                       ULICE ,
                       CISLO_POPISNE ,
                       MESTO ,
                       PSC ,
                       STAT_NAZEV ,
                       CELA_ADRESA ,
                       CENA_ZA_OSOBU ,
                       SLEVA_PROCENT ,
                       DOPRAVA_NAZEV ,
                       STRAVA_NAZEV ,
                       DOPRAVA_ID ,
                       STRAVA_ID,
                       count(*) over () as pocet_radku
                    FROM ZAJEZD_SPRAVA_VIEW
                   /**where**/
                   offset {start} rows fetch next {pocetRadku} rows only
                   """;
        var builder = new SqlBuilder();
        var template = builder.AddTemplate(sql);
        if (ubytovani != "")
            builder.Where("LOWER(ubytovani_nazev) like :ubytovani", new { ubytovani = $"%{ubytovani.ToLower()}%" });
        if (adresa != "")
            builder.Where("LOWER(cela_adresa) like :adresa", new { adresa = $"%{adresa.ToLower()}%" });
        if (cenaOd != null)
            builder.Where("cena_za_osobu >= :cenaOd", new { cenaOd = cenaOd.ToString() });
        if (cenaDo != null)
            builder.Where("cena_za_osobu <= :cenaDo", new { cenaDo = cenaDo.ToString() });
        if (slevaOd != null)
            builder.Where("NVL(sleva_procent, 0) >= :slevaOd", new { slevaOd = slevaOd.ToString() });
        if (slevaDo != null)
            builder.Where("NVL(sleva_procent, 0) <= :slevaDo", new { slevaDo = slevaDo.ToString() });
        if (dopravaId != null)
            builder.Where("doprava_id = :dopravaId", new { dopravaId = dopravaId.ToString() });
        if (stravaId != null)
            builder.Where("strava_id = :stravaId", new { stravaId = stravaId.ToString() });

        var rows = UnitOfWork.Connection.Query<dynamic>(template.RawSql, template.Parameters);
        var model = rows.Select(row =>
        {
            var zajezd = new ZajezdModel
            {
                ZajezdId = EncodeId((int)row.ZAJEZD_ID),
                Ubytovani = new UbytovaniModel
                {
                    Nazev = row.UBYTOVANI_NAZEV,
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
                },
                SlevaProcent = (int?)row.SLEVA_PROCENT,
                CenaZaOsobu = (double)row.CENA_ZA_OSOBU,
                Doprava = new DopravaModel
                {
                    Nazev = row.DOPRAVA_NAZEV
                },
                Strava = new StravaModel
                {
                    Nazev = row.STRAVA_NAZEV
                }
            };

            return zajezd;
        });

        celkovyPocetRadku = Convert.ToInt32(rows.FirstOrDefault()?.POCET_RADKU ?? 0);
        return model;
    }

    private Zajezd MapToDto(ZajezdModel model) => new()
    {
        ZajezdId = DecodeId(model.ZajezdId),
        Popis = model.Popis,
        CenaZaOsobu = model.CenaZaOsobu,
        SlevaProcent = model.SlevaProcent,
        Zobrazit = model.Zobrazit ? 1 : 0,
        DopravaId = DecodeIdOrDefault(model.Doprava.DopravaId),
        UbytovaniId = DecodeIdOrDefault(model.Ubytovani.UbytovaniId),
        StravaId = DecodeIdOrDefault(model.Strava.StravaId)
    };
    //
    // private ZajezdModel MapRowToModel(ZajezdModel zamestnanec, RoleModel role,
    //     PrihlasovaciUdajeModel prihlasovaciUdaje, ZamestnanecModel? nadrizeny)
    // {
    //     zamestnanec.ZamestnanecId = EncodeId(zamestnanec.ZamestnanecId);
    //
    //     role.RoleId = EncodeId(role.RoleId);
    //     zamestnanec.Role = role;
    //
    //     prihlasovaciUdaje.PrihlasovaciUdajeId = EncodeId(prihlasovaciUdaje.PrihlasovaciUdajeId);
    //     prihlasovaciUdaje.Heslo = null;
    //     zamestnanec.PrihlasovaciUdaje = prihlasovaciUdaje;
    //
    //     if (nadrizeny != null)
    //         nadrizeny.ZamestnanecId = EncodeId(nadrizeny.ZamestnanecId);
    //     zamestnanec.Nadrizeny = nadrizeny;
    //
    //     return zamestnanec;
    // }
}