using System.Transactions;
using app.DAL;
using app.DAL.Models;
using app.Models;
using app.Models.Sprava;
using app.Utils;
using Dapper;

namespace app.Repositories;

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

    public RoleModel Get(int id) => Get(_roleDao, id, MapToModel);

    public IEnumerable<RoleModel> GetAll() => GetAll(_roleDao, MapToModel);

    private RoleModel MapToModel(Role dto) => new()
    {
        RoleId = EncodeId(dto.RoleId),
        Nazev = dto.Nazev
    };

    private Role MapToDto(RoleModel model) => new()
    {
        RoleId = DecodeId(model.RoleId),
        Nazev = model.Nazev
    };
}