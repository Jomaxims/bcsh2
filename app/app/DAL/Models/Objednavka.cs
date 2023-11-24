namespace app.DAL.Models;

public class Objednavka : IDbModel
{
    public int? ObjednavkaId { get; set; }
    public required int PocetOsob { get; set; }
    public required int TerminyId { get; set; }
    public int? PojisteniId { get; set; }
    public required int PokojId { get; set; }
    public required int ZakaznikId { get; set; }
    public required int PlatbaId { get; set; }
}