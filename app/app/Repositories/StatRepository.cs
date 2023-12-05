using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;
using Dapper;

namespace app.Repositories;

/// <summary>
/// Repository pro práci se státy
/// </summary>
public class StatRepository : BaseRepository
{
    private readonly GenericDao<Stat> _statDao;

    public StatRepository(
        ILogger<DopravaRepository> logger,
        IDbUnitOfWork unitOfWork,
        IIdConverter idConverter,
        GenericDao<Stat> statDao
    ) : base(logger, unitOfWork, idConverter)
    {
        _statDao = statDao;
    }

    /// <summary>
    /// Přidá nebo upraví (pokud má id) stát
    /// </summary>
    /// <param name="model">Stát</param>
    /// <returns>id státu</returns>
    public int AddOrEdit(StatModel model)
    {
        return AddOrEdit(_statDao, model, MapToDto);
    }

    /// <summary>
    /// Smaže stát
    /// </summary>
    /// <param name="id">id státu</param>
    public void Delete(int id)
    {
        Delete(_statDao, id);
    }

    /// <summary>
    /// Získá stát
    /// </summary>
    /// <param name="id">id státu</param>
    /// <returns></returns>
    public StatModel Get(int id)
    {
        return Get(_statDao, id, MapToModel);
    }

    /// <summary>
    /// Vrátí id České republiky
    /// </summary>
    /// <returns></returns>
    public int GetCzId()
    {
        return UnitOfWork.Connection.ExecuteScalar<int>("select stat_id from stat where ZKRATKA = 'CZE'");
    }

    /// <summary>
    /// Vrátí všechny státy dle filtrů
    /// </summary>
    /// <param name="celkovyPocetRadku">Celkový počet řádků</param>
    /// <param name="zkratka">Zkratka státu</param>
    /// <param name="nazev">Název státu</param>
    /// <param name="start">První řádek stránkování</param>
    /// <param name="pocetRadku">Počet položek</param>
    /// <returns></returns>
    public IEnumerable<StatModel> GetAll(out int celkovyPocetRadku, string zkratka = "", string nazev = "",
        int start = 0, int pocetRadku = 0)
    {
        var _celkovyPocetRadku = -1;
        var sql = $"""
                       select stat_id, zkratka, nazev, count(*) over () as pocet_radku
                       from stat
                       /**where**/
                       order by zkratka
                       offset {start} rows fetch next {pocetRadku} rows only
                   """;
        var builder = new SqlBuilder();
        var template = builder.AddTemplate(sql);
        if (zkratka != "")
            builder.Where("LOWER(zkratka) like :zkratka", new { zkratka = $"%{zkratka.ToLower()}%" });
        if (nazev != "")
            builder.Where("LOWER(nazev) like :nazev", new { nazev = $"%{nazev.ToLower()}%" });

        var model = UnitOfWork.Connection.Query<StatModel, decimal, StatModel>(template.RawSql, (stat, pocet_radku) =>
        {
            if (_celkovyPocetRadku == -1)
                _celkovyPocetRadku = Convert.ToInt32(pocet_radku);

            stat.StatId = EncodeId(stat.StatId);

            return stat;
        }, template.Parameters, splitOn: "pocet_radku");

        celkovyPocetRadku = _celkovyPocetRadku;

        return model;
    }

    /// <summary>
    /// Mapovací funkce
    /// </summary>
    /// <param name="dto"></param>
    /// <returns></returns>
    private StatModel MapToModel(Stat dto)
    {
        return new StatModel
        {
            StatId = EncodeId(dto.StatId),
            Nazev = dto.Nazev,
            Zkratka = dto.Zkratka
        };
    }

    /// <summary>
    /// Mapovací funkce
    /// </summary>
    /// <param name="model"></param>
    /// <returns></returns>
    private Stat MapToDto(StatModel model)
    {
        return new Stat
        {
            StatId = DecodeId(model.StatId),
            Nazev = model.Nazev,
            Zkratka = model.Zkratka
        };
    }
}