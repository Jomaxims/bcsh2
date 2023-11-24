namespace app.DAL.Models;

public class Pokoj : IDbModel
{
    public int? PokojId { get; set; }
    public required int PocetMist { get; set; }
    public required string Nazev { get; set; }
}