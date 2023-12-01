using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;

namespace app.Repositories;

/// <summary>
/// Repository pro práci s rolemi
/// </summary>
public class RoleRepository : BaseRepository
{
    private readonly GenericDao<Role> _roleDao;

    public RoleRepository(
        ILogger<RoleRepository> logger,
        IDbUnitOfWork unitOfWork,
        IIdConverter idConverter,
        GenericDao<Role> roleDao
    ) : base(logger, unitOfWork, idConverter)
    {
        _roleDao = roleDao;
    }

    /// <summary>
    /// Získá všechny role zaměstnanců
    /// </summary>
    /// <returns></returns>
    public IEnumerable<RoleModel> GetAll()
    {
        return GetAll(_roleDao, MapToModel);
    }

    /// <summary>
    /// Mapovací funkce
    /// </summary>
    /// <param name="dto"></param>
    /// <returns></returns>
    private RoleModel MapToModel(Role dto)
    {
        return new RoleModel
        {
            RoleId = EncodeId(dto.RoleId),
            Nazev = dto.Nazev
        };
    }
}