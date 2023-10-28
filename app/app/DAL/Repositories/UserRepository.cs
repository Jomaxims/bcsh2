namespace app.DAL.Repositories;

public interface IUserRepository
{
    
}

public class UserRepository : RepositoryBase, IUserRepository
{
    public UserRepository(IDbUnitOfWork unitOfWork) : base(unitOfWork)
    {
    }
}