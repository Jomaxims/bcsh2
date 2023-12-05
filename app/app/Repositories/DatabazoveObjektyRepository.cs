using app.DAL;
using app.Utils;
using Dapper;

namespace app.Repositories;

/// <summary>
/// Repository pro práci s databázovými objekty
/// </summary>
public class DatabazoveObjektyRepository : BaseRepository
{
    public DatabazoveObjektyRepository(ILogger<DatabazoveObjektyRepository> logger, IDbUnitOfWork unitOfWork, IIdConverter idConverter) : base(
        logger, unitOfWork, idConverter)
    {
    }

    /// <summary>
    /// Získá všechny tabulky
    /// </summary>
    /// <returns></returns>
    public IEnumerable<string> GetTabulky()
    {
        return UnitOfWork.Connection.Query<string>("select JMENO_OBJEKTU from tabulky_view");
    }
    
    /// <summary>
    /// Získá všechny pohledy
    /// </summary>
    /// <returns></returns>
    public IEnumerable<string> GetPohledy()
    {
        return UnitOfWork.Connection.Query<string>("select JMENO_OBJEKTU from pohledy_view");
    }
    
    /// <summary>
    /// Získá všechny indexy
    /// </summary>
    /// <returns></returns>
    public IEnumerable<string> GetIndexy()
    {
        return UnitOfWork.Connection.Query<string>("select JMENO_OBJEKTU from indexy_view");
    }
    
    /// <summary>
    /// Získá všechny package
    /// </summary>
    /// <returns></returns>
    public IEnumerable<string> GetPackage()
    {
        return UnitOfWork.Connection.Query<string>("select JMENO_OBJEKTU from package_view");
    }
    
    /// <summary>
    /// Získá všechny procedury
    /// </summary>
    /// <returns></returns>
    public IEnumerable<string> GetProcedury()
    {
        return UnitOfWork.Connection.Query<string>("select JMENO_OBJEKTU from procedury_view");
    }
    
    /// <summary>
    /// Získá všechny funkce
    /// </summary>
    /// <returns></returns>
    public IEnumerable<string> GetFunkce()
    {
        return UnitOfWork.Connection.Query<string>("select JMENO_OBJEKTU from funkce_view");
    }
    
    /// <summary>
    /// Získá všechny triggery
    /// </summary>
    /// <returns></returns>
    public IEnumerable<string> GetTriggry()
    {
        return UnitOfWork.Connection.Query<string>("select JMENO_OBJEKTU from triggry_view");
    }
    
    /// <summary>
    /// Získá všechny sekvence
    /// </summary>
    /// <returns></returns>
    public IEnumerable<string> GetSekvence()
    {
        return UnitOfWork.Connection.Query<string>("select JMENO_OBJEKTU from sekvence_view");
    }
}