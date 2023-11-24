namespace app.DAL.Models;

public class ObrazkyUbytovani : IDbModel
{
    public int? ObrazkyUbytovaniId { get; set; }
    public required byte[] Obrazek { get; set; }
    public required string Nazev { get; set; }
    public required int UbytovaniId { get; set; }
}