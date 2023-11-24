namespace app.DAL.Models;

public class Strava : IDbModel
{
    public int? StravaId { get; set; }
    public required string Nazev { get; set; }
}