namespace app.DAL.Models;

public class Platba : IDbModel
{
    public int? PlatbaId { get; set; }
    public required double Castka { get; set; }
    public required bool Zaplacena { get; set; }
    public string? CisloUctu { get; set; }
    public required int ObjednavkaId { get; set; }
}