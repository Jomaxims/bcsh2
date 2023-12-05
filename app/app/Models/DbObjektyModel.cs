namespace app.Models;

public class DbObjektyModel
{
    public required IEnumerable<string> Tabulky { get; set; }
    public required IEnumerable<string> Pohledy { get; set; }
    public required IEnumerable<string> Indexy { get; set; }
    public required IEnumerable<string> Package { get; set; }
    public required IEnumerable<string> Procedury { get; set; }
    public required IEnumerable<string> Funkce { get; set; }
    public required IEnumerable<string> Triggery { get; set; }
    public required IEnumerable<string> Sekvence { get; set; }
}