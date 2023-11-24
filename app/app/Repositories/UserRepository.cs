using app.DAL;
using app.Utils;

namespace app.Repositories;

public class UserRepository : RepositoryBase
{
    public UserRepository(IDbUnitOfWork unitOfWork, IIdConverter idConverter) : base(unitOfWork, idConverter)
    {
    }
}