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

/// <summary>
/// Implementace unit of work patternu pro práci s repository. Obstarává spojení a transakce.
/// </summary>
internal sealed class DbUnitOfWork : IDbUnitOfWork
{
    private readonly IDbConnectionFactory _connectionFactory;
    private IDbConnection? _connection;

    public DbUnitOfWork(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    /// <summary>
    /// Otevře nové spojení, nebo vrátí již otevřené spojení.
    /// </summary>
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

    /// <summary>
    /// Vrátí současnou transakci nebo null.
    /// </summary>
    public IDbTransaction? Transaction { get; private set; }

    /// <summary>
    /// Započne novou transakci.
    /// </summary>
    public void BeginTransaction()
    {
        Transaction = Connection.BeginTransaction();
    }

    /// <summary>
    /// Commitne současnou transakci, pokud existuje.
    /// </summary>
    public void Commit()
    {
        Transaction?.Commit();
        Dispose();
    }

    /// <summary>
    /// Rollbackne současnou transakci, pokud existuje.
    /// </summary>
    public void Rollback()
    {
        Transaction?.Rollback();
        Dispose();
    }

    /// <summary>
    /// Zahodí současné spojení a transakci
    /// </summary>
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