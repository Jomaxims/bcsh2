namespace app.DAL.Models;

public class Zakaznik : IDbModel
{
    public int? ZakaznikId { get; set; }
    public required int PrihlasovaciUdajeId { get; set; }
    public required int OsobaId { get; set; }
    public required int KontakId { get; set; }
    public required int AdresaId { get; set; }
}