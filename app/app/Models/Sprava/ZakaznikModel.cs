namespace app.Models.Sprava;

public class ZakaznikModel
{
    public string ZakaznikId { get; set; }

    [Required(ErrorMessage = "Zadejte přihlašovací údaje")]
    [Display(Name = "Přihlašovací údaje")]
    public PrihlasovaciUdajeModel PrihlasovaciUdaje { get; set; }

    [Required(ErrorMessage = "Zadejte osobu")]
    [Display(Name = "Osoba")]
    public OsobaModel Osoba { get; set; }

    [Required(ErrorMessage = "Zadejte kontakt")]
    [Display(Name = "Kontakt")]
    public KontaktModel Kontakt { get; set; }

    [Required(ErrorMessage = "Zadejte adresu")]
    [Display(Name = "Adresa")]
    public AdresaModel Adresa { get; set; }
}