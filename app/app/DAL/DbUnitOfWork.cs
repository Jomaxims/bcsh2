using System.Data;

namespace app.DAL;

// https://stackoverflow.com/a/45029588
// https://github.com/pimbrouwers/LunchPail/blob/master/src/LunchPail/DbContext.cs
public interface IDbUnitOfWork : IDisposable
{
    IDbConnection Connection { get; }
    IDbTransaction? Transaction { get; }
    void BeginTransaction();
    void Commit();
    void Rollback();
    void Reset();
}

internal sealed class DbUnitOfWork : IDbUnitOfWork
{
    private readonly IDbConnectionFactory _connectionFactory;
    private IDbConnection? _connection;

    public DbUnitOfWork(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public IDbConnection Connection
    {
        get
        {
            if (_connection != null) return _connection;

            _connection = _connectionFactory.NewConnection();
            _connection.Open();

            return _connection;
        }
    }

    public IDbTransaction? Transaction { get; private set; }

    public void BeginTransaction()
    {
        Transaction = Connection.BeginTransaction();
    }

    public void Commit()
    {
        Transaction?.Commit();
        Dispose();
    }

    public void Rollback()
    {
        Transaction?.Rollback();
        Dispose();
    }

    public void Reset()
    {
        _connection?.Close();
        _connection?.Dispose();
        Transaction?.Dispose();

        _connection = null;
        Transaction = null;
    }

    public void Dispose()
    {
        _connection?.Close();
        _connection?.Dispose();
        Transaction?.Dispose();

        _connection = null;
        Transaction = null;
    }
}