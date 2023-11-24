namespace app.DAL.Models;

public class Zajezd : IDbModel
{
    public int? ZajezdId { get; set; }
    public required string Popis { get; set; }
    public required double CenaZaOsobu { get; set; }
    public required int? SlevaProcent { get; set; }
    public required bool Zobrazit { get; set; }
    public required int DopravaId { get; set; }
    public required int UbytovaniId { get; set; }
    public required int StravaId { get; set; }
}