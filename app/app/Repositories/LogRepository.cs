using app.DAL;
using app.DAL.Models;
using app.Models;
using app.Utils;
using Dapper;

namespace app.Repositories;

public class LogRepository : BaseRepository
{
    private readonly GenericDao<Log> _logDao;

    public LogRepository(
        ILogger<LogRepository> logger,
        IDbUnitOfWork unitOfWork,
        IIdConverter idConverter,
        GenericDao<Log> logDao
    ) : base(logger, unitOfWork, idConverter)
    {
        _logDao = logDao;
    }

    public IEnumerable<LogModel> GetAll(out int celkovyPocetRadku, string tabulka = "", string operace = "",
        DateOnly datumOd = default, DateOnly datumDo = default, int start = 0, int pocetRadku = 0)
    {
        var _celkovyPocetRadku = -1;
        var sql = $"""
                   select TABULKA, OPERACE, CAS_ZMENY, UZIVATEL, PRED, PO, count(*) over () as pocet_radku
                       from log_table
                       /**where**/
                       order by CAS_ZMENY desc
                       offset {start} rows fetch next {pocetRadku} rows only
                   """;
        var builder = new SqlBuilder();
        var template = builder.AddTemplate(sql);
        if (tabulka != "")
            builder.Where("LOWER(tabulka) like :tabulka", new { tabulka });
        if (operace != "")
            builder.Where("LOWER(operace) like :operace", new { operace });
        if (datumOd != default)
            builder.Where("CAS_ZMENY >= TO_DATE(:datumOd, 'YYYY-MM-DD')", new { datumOd = datumOd.ToString("o") });
        if (datumDo != default)
            builder.Where("CAS_ZMENY <= TO_DATE(:datumDo, 'YYYY-MM-DD')", new { datumDo = datumDo.ToString("o") });

        var model = UnitOfWork.Connection.Query<LogModel, decimal, LogModel>(template.RawSql, (log, pocet_radku) =>
        {
            if (_celkovyPocetRadku == -1)
                _celkovyPocetRadku = Convert.ToInt32(pocet_radku);

            return log;
        }, template.Parameters, splitOn: "pocet_radku");

        celkovyPocetRadku = _celkovyPocetRadku;
        return model;
    }
}