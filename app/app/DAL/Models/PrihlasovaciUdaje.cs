namespace app.DAL.Models;

public class PrihlasovaciUdaje : IDbModel
{
    public int? PrihlasovaciUdajeId { get; set; }
    public required string Jmeno { get; set; }
    public required string Heslo { get; set; }
}