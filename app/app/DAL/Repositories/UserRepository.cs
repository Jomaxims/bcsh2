namespace app.DAL.Repositories;

public class UserRepository : RepositoryBase
{
    public UserRepository(IDbUnitOfWork unitOfWork) : base(unitOfWork)
    {
    }
}