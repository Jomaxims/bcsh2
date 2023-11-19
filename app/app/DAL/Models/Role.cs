namespace app.DAL.Models;

public class Role : IDbModel
{
    public int? RoleId { get; set; }
    public required string Nazev { get; set; }
}