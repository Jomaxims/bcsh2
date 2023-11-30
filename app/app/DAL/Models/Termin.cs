namespace app.DAL.Models;

public class Termin : IDbModel
{
    public int? TerminId { get; set; }
    public required DateOnly Od { get; set; }
    public required DateOnly Do { get; set; }
    public required int ZajezdId { get; set; }
}