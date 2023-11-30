using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;
using Dapper;

namespace app.Repositories;

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

    public int AddOrEdit(StatModel model) => AddOrEdit(_statDao, model, MapToDto);

    public void Delete(int id) => Delete(_statDao, id);

    public StatModel Get(int id) => Get(_statDao, id, MapToModel);

    public int GetCzId() => UnitOfWork.Connection.ExecuteScalar<int>("select stat_id from stat where ZKRATKA = 'CZE'");
    
    public IEnumerable<StatModel> GetAll(out int celkovyPocetRadku, string zkratka = "", string nazev = "", int start = 0, int pocetRadku = 0)
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

    private StatModel MapToModel(Stat dto) => new()
    {
        StatId = EncodeId(dto.StatId),
        Nazev = dto.Nazev,
        Zkratka = dto.Zkratka
    };
    
    private Stat MapToDto(StatModel model) => new()
    {
        StatId = DecodeId(model.StatId),
        Nazev = model.Nazev,
        Zkratka = model.Zkratka
    };
}