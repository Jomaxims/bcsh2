namespace app.DAL.Models;

public class Log : IDbModel
{
    public int? LogId { get; set; }
    public required string Tabulka { get; set; }
    public required string Operace { get; set; }
    public required DateTime CasZmeny { get; set; }
    public required string Uzivatel { get; set; }
    public string? Pred { get; set; }
    public string? Po { get; set; }
}