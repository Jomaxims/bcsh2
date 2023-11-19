using System.Data;

namespace app.DAL.Repositories;

public abstract class RepositoryBase
{
    protected readonly IDbUnitOfWork UnitOfWork;

    protected RepositoryBase(IDbUnitOfWork unitOfWork)
    {
        UnitOfWork = unitOfWork;
    }
}