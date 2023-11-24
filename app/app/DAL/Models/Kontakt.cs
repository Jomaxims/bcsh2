namespace app.DAL.Models;

public class Kontakt : IDbModel
{
    public int? KontaktId { get; set; }
    public required string Email { get; set; }
    public required string Telefon { get; set; }
}