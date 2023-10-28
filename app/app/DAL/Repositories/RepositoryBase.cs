using System.Data;

namespace app.DAL.Repositories;

public abstract class RepositoryBase
{
    protected IDbUnitOfWork UnitOfWork;

    protected RepositoryBase(IDbUnitOfWork unitOfWork)
    {
        UnitOfWork = unitOfWork;
    }
}