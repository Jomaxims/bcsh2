namespace app.DAL.Models;

public class Doprava : IDbModel
{
    public int? DopravaId { get; set; }
    public required string Nazev { get; set; }
}