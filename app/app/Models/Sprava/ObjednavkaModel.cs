namespace app.Models.Sprava;

public class ObjednavkaModel
{
    public string ObjednavkaId { get; set; }

    [Required(ErrorMessage = "Zadejte počet osob")]
    [Display(Name = "Počet osob")]
    [Range(1, int.MaxValue, ErrorMessage = "Objednávka musí mít minimálně 1 osobu")]
    public int PocetOsob { get; set; }

    [Required(ErrorMessage = "Zadejte osoby")]
    [Display(Name = "Osoby")]
    public OsobaModel[] Osoby { get; set; }

    [Required(ErrorMessage = "Zadejte zákazníka")]
    [Display(Name = "Zákazník")]
    public ZakaznikModel Zakaznik { get; set; }

    [Required(ErrorMessage = "Zadejte termín")]
    [Display(Name = "Termín")]
    public TerminModel Termin { get; set; }

    [Required(ErrorMessage = "Zadejte pokoj")]
    [Display(Name = "Pokoj")]
    public PokojModel Pokoj { get; set; }

    [Required(ErrorMessage = "Zadejte zájezd")]
    [Display(Name = "Zájezd")]
    public ZajezdModel Zajezd { get; set; }

    [Required(ErrorMessage = "Zadejte platbu")]
    [Display(Name = "Platba")]
    public PlatbaModel Platba { get; set; }

    [Required(ErrorMessage = "Zadejte pojištění")]
    [Display(Name = "Pojištění")]
    public PojisteniModel Pojisteni { get; set; }
}