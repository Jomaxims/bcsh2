using System.Data;
using System.Text.Json;
using System.Text.Json.Serialization;
using Dapper;

namespace app.DAL;

public class DbResult
{
    [JsonPropertyName("message")]
    public required string Message { get; set; }
    
    [JsonPropertyName("status")]
    public required string Status { get; set; }
    
    [JsonPropertyName("id")]
    public int? Id { get; set; }

    public bool IsOk => Status == "OK";

    public DbResult AddId(int id)
    {
        Id = id;
        
        return this;
    }
    
    public override string ToString()
    {
        return $"{nameof(Message)}: {Message}, {nameof(Status)}: {Status}, {nameof(Id)}: {Id}";
    }
}

public class DatabaseManager : IDisposable
{
    private readonly ILogger<DatabaseManager> _logger;
    private readonly IDbUnitOfWork _dbUnitOfWork;

    public DatabaseManager(ILogger<DatabaseManager> logger, IDbConnectionFactory dbConnectionFactory)
    {
        _logger = logger;
        _dbUnitOfWork = new DbUnitOfWork(dbConnectionFactory);
    }

    public void CreateTables()
    {
        try
        {
            var script = File.ReadAllText("./generace.ddl");
            var scriptLines = script.Split("\n", StringSplitOptions.RemoveEmptyEntries);

            for (var i = 0; i < scriptLines.Length; i++)
            {
                if (scriptLines[i].StartsWith("--"))
                {
                    scriptLines[i] = "";
                }
            }
            
            var commandStrings = string.Join("", scriptLines).Split(";", StringSplitOptions.RemoveEmptyEntries);

            foreach (var command in commandStrings)
            {
                _dbUnitOfWork.Connection.Execute(command);
            }
        }
        catch (Exception e)
        {
            _logger.LogTrace("{}", e.Message);
            throw;
        }
    }

    public void TestProcedure()
    {
        var parameters = new DynamicParameters();
        parameters.Add("i_stat_id", 10);
        parameters.Add("i_zkratka", "PL");
        parameters.Add("i_nazev", "Polsko");
        parameters.Add("o_result", dbType: DbType.String, direction: ParameterDirection.Output, size: 1000);

        _dbUnitOfWork.Connection.Query("stat_package.manage_stat", parameters, commandType: CommandType.StoredProcedure);

        var res = JsonSerializer.Deserialize<DbResult>(parameters.Get<string>("o_result"));
        Console.WriteLine(res);
    }

    public void Dispose()
    {
        _dbUnitOfWork.Dispose();
    }
}