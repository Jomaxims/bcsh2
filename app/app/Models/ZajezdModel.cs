namespace app.Models;

public class ZajezdModel
{
    public required int CenaZaOsobu { get; set; }
    public required string Doprava { get; set; }
    public int? CenaPredSlevou { get; set; }
    public required UbytovaniModel Ubytovani { get; set; }
    public required string Strava { get; set; }
    public required IEnumerable<TerminModel> Terminy { get; set; }
    public required IEnumerable<PojisteniModel> Pojisteni { get; set; }
}

public class TerminModel
{
    public required string Id { get; set; }
    public required DateOnly Od { get; set; }
    public required DateOnly Do { get; set; }
    public required IEnumerable<PokojModel> Pokoje { get; set; }
    
    public string OdDo => $"{Od.ToShortDateString()} - {Do.ToShortDateString()}";
}

public class PokojModel
{
    public required string Id { get; set; }
    public required string Nazev { get; set; }
    public required int PocetMist { get; set; }
}

public class UbytovaniModel
{
    public required IEnumerable<string> ObrazkyIds { get; set; }
    public required string Nazev { get; set; }
    public required int PocetHvezd { get; set; }
    public required string Lokalita { get; set; }
    public required string Popis { get; set; }
}

public class PojisteniModel
{
    public required string Id { get; set; }
    public required int CenaZaDen { get; set; }
    public required string Popis { get; set; }
    
    public string Nazev => $"{Popis} - {CenaZaDen} Kč";
}