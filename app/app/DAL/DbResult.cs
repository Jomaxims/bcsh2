using System.Text.Json.Serialization;
using app.Repositories;

namespace app.DAL;

public class DbResult
{
    [JsonPropertyName("message")] public required string Message { get; set; }

    [JsonPropertyName("status")] public required string Status { get; set; }

    [JsonPropertyName("id")] public int Id { get; set; }

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

    public void IsOkOrThrow()
    {
        if (!IsOk)
            throw new DatabaseException(Message);
    }
}