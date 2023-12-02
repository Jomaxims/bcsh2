using System.Text.Json.Serialization;
using app.Repositories;

namespace app.DAL;

/// <summary>
/// Třídá, kterou vrací obslužné procedury v databázi formou JSON.
/// </summary>
public class DbResult
{
    [JsonPropertyName("message")] public required string Message { get; set; }

    [JsonPropertyName("status")] public required string Status { get; set; }

    [JsonPropertyName("id")] public int Id { get; set; }

    /// <summary>
    /// Zda operace proběhla úspěšně
    /// </summary>
    public bool IsOk => Status == "OK";

    /// <summary>
    /// Získá záznamu v datanázi pro procedury manage
    /// </summary>
    /// <param name="id">id záznamu</param>
    /// <returns></returns>
    public DbResult AddId(int id)
    {
        Id = id;

        return this;
    }

    public override string ToString()
    {
        return $"{nameof(Message)}: {Message}, {nameof(Status)}: {Status}, {nameof(Id)}: {Id}";
    }

    /// <summary>
    /// Vyhodí DatabaseException pokud operace neproběhla úspěšně
    /// </summary>
    /// <exception cref="DatabaseException"></exception>
    public void IsOkOrThrow()
    {
        if (!IsOk)
            throw new DatabaseException(Message);
    }
}