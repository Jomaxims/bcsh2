namespace app.DAL.Models;

public class Termin : IDbModel
{
    public int? TerminId { get; set; }
    public required DateTime Od { get; set; }
    public required DateTime Do { get; set; }
    public required int ZajezdId { get; set; }
}