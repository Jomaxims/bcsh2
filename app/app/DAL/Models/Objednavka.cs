namespace app.DAL.Models;

public class Objednavka : IDbModel
{
    public int? ObjednavkaId { get; set; }
    public required int PocetOsob { get; set; }
    public required int TerminId { get; set; }
    public required int PojisteniId { get; set; }
    public required int PokojId { get; set; }
    public required int ZakaznikId { get; set; }
}