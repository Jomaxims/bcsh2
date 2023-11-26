namespace app.DAL.Models;

public class Osoba : IDbModel
{
    public int? OsobaId { get; set; }
    public required string Jmeno { get; set; }
    public required string Prijmeni { get; set; }
    public required DateOnly DatumNarozeni { get; set; }
}