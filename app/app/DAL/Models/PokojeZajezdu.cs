namespace app.DAL.Models;

public class PokojeTerminu : IDbModel
{
    public required int CelkovyPocetPokoju { get; set; }
    public required int PocetObsazenychPokoju { get; set; }
    public required int TerminyId { get; set; }
    public required int PokojId { get; set; }
}