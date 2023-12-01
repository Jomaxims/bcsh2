using System.Data;
using Oracle.ManagedDataAccess.Client;

namespace app.DAL;

public interface IDbConnectionFactory
{
    public IDbConnection NewConnection();
}

public class DbConnectionFactory : IDbConnectionFactory
{
    private readonly IConfiguration _configuration;

    public DbConnectionFactory(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public IDbConnection NewConnection()
    {
        return new OracleConnection(_configuration.GetConnectionString("DbConnection"));
    }
}