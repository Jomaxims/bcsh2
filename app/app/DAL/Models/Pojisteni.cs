using app.DAL.Models;

namespace app.DAL;

public class Pojisteni : IDbModel
{
    public int? PojisteniId { get; set; }
    public required double CenaZaDen { get; set; }
    public required string Nazev { get; set; }
}