namespace app.DAL.Models;

public class Zamestnanec : IDbModel
{
    public int? ZamestnanecId { get; set; }
    public required string Jmeno { get; set; }
    public required string Prijmeni { get; set; }
    public required int RoleId { get; set; }
    public required int PrihlasovaciUdajeId { get; set; }
    public int? NadrizenyId { get; set; }
}