using Dapper;

namespace app.DAL;

public class DatabaseManager : IDisposable
{
    private readonly IDbUnitOfWork _dbUnitOfWork;
    private readonly ILogger<DatabaseManager> _logger;

    public DatabaseManager(ILogger<DatabaseManager> logger, IDbConnectionFactory dbConnectionFactory)
    {
        _logger = logger;
        _dbUnitOfWork = new DbUnitOfWork(dbConnectionFactory);
    }

    public void Dispose()
    {
        _dbUnitOfWork.Dispose();
    }

    public void CreateTables()
    {
        try
        {
            var script = File.ReadAllText("./generace.ddl");
            var scriptLines = script.Split("\n", StringSplitOptions.RemoveEmptyEntries);

            for (var i = 0; i < scriptLines.Length; i++)
                if (scriptLines[i].StartsWith("--"))
                    scriptLines[i] = "";

            var commandStrings = string.Join("", scriptLines).Split(";", StringSplitOptions.RemoveEmptyEntries);

            foreach (var command in commandStrings) _dbUnitOfWork.Connection.Execute(command);
        }
        catch (Exception e)
        {
            _logger.LogTrace("{}", e.Message);
            throw;
        }
    }
}