namespace app.DAL.Models;

public class Adresa : IDbModel
{
    public int? AdresaId { get; set; }
    public required string Ulice { get; set; }
    public required string CisloPopisne { get; set; }
    public required string Mesto { get; set; }
    public required string Psc { get; set; }
    public string? Poznamka { get; set; }
    public required int StatId { get; set; }
}