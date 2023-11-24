namespace app.Models.Sprava;

public class TerminModel
{
    public string TerminId { get; set; }
    
    [Required(ErrorMessage = "Zadejte datum od")]
    [Display(Name = "Datum od")]
    [DataType(DataType.Date)]
    public DateOnly Od { get; set; }
    
    [Required(ErrorMessage = "Zadejte datum do")]
    [Display(Name = "Datum do")]
    [DataType(DataType.Date)]
    public DateOnly Do { get; set; }
    
    [Required(ErrorMessage = "Zadejte pokoje termínu")]
    [Display(Name = "Pokoje termínu")]
    public IEnumerable<PokojTerminu> PokojeTerminu { get; set; }
}

public class PokojTerminu
{
    [Required(ErrorMessage = "Zadejte celkový počet pokojů")]
    [Display(Name = "Celkový počet pokojů")]
    public int CelkovyPocetPokoju { get; set; }
    
    [Required(ErrorMessage = "Zadejte počet obsazených pokojů")]
    [Display(Name = "Počet obsazených pokojů")]
    public int PocetObsazenychPokoju { get; set; }
    
    [Required(ErrorMessage = "Zadejte pokoj")]
    [Display(Name = "Pokoj")]
    public PokojModel Pokoj { get; set; }
}