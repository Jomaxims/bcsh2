namespace app.DAL.Models;

public class Stat : IDbModel
{
    public int? StatId { get; set; }
    public required string Zkratka { get; set; }
    public required string Nazev { get; set; }
}