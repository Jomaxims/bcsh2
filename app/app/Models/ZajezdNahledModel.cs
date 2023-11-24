namespace app.Models;

public class ZajezdNahledModel
{
    public required string Id { get; set; }
    public required string FotoId { get; set; }
    public required string Nazev { get; set; }
    public required int PocetHvezd { get; set; }
    public required string Lokalita { get; set; }
    public required string ZkracenyPopis { get; set; }
    public required string Doprava { get; set; }
    public required string Strava { get; set; }
    public required int CenaZaOsobu { get; set; }
    public int? CenaPredSlevou { get; set; }
    public required string Od { get; set; }
    public required string Do { get; set; }
}