namespace app.DAL.Models;

public class Zamestnanec : IDbModel
{
    public int? ZamestnanecId { get; set; }
    public required int IdRole { get; set; }
    public required int PrihlasovaciUdajeId { get; set; }
    public int? NadrizenyId { get; set; }
}