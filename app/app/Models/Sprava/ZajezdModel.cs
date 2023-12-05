namespace app.Models.Sprava;

public class ZajezdModel
{
    public string ZajezdId { get; set; }

    [Display(Name = "Popis")]
    [DataType(DataType.Text)]
    public string? Popis { get; set; }

    [Required(ErrorMessage = "Zadejte cenu za osobu")]
    [Display(Name = "Cena za osobu")]
    [Range(1, int.MaxValue, ErrorMessage = "Zadejte platnou cenu")]
    public double CenaZaOsobu { get; set; }

    [Display(Name = "Sleva (%)")]
    [Range(0, 100, ErrorMessage = "Sleva musí být mezi 0 a 100")]
    public int? SlevaProcent { get; set; }

    [Required(ErrorMessage = "Zadejte zobrazení")]
    [Display(Name = "Zobrazit")]
    public bool Zobrazit { get; set; }

    [Required(ErrorMessage = "Zadejte termíny")]
    [Display(Name = "Termíny")]
    public IEnumerable<TerminModel>? Terminy { get; set; }

    [Required(ErrorMessage = "Zadejte ubytování")]
    [Display(Name = "Ubytování")]
    public UbytovaniModel Ubytovani { get; set; }

    [Required(ErrorMessage = "Zadejte dopravu")]
    [Display(Name = "Doprava")]
    public DopravaModel Doprava { get; set; }

    [Required(ErrorMessage = "Zadejte stravu")]
    [Display(Name = "Strava")]
    [DataType(DataType.Text)]
    public StravaModel Strava { get; set; }
}