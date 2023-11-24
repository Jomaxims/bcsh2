namespace app.DAL.Models;

public class Ubytovani : IDbModel
{
    public int? UbytovaniId { get; set; }
    public required string Nazev { get; set; }
    public required string Popis { get; set; }
    public required int PocetHvezd { get; set; }
    public required int AdresaId { get; set; }
}