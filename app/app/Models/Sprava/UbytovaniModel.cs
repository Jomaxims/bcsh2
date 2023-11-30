namespace app.Models.Sprava;

public class UbytovaniModel
{
    public string UbytovaniId { get; set; }
    
    [Required(ErrorMessage = "Zadejte název")]
    [Display(Name = "Název")]
    [DataType(DataType.Text)]
    public string Nazev { get; set; }
    
    [Required(ErrorMessage = "Zadejte popis")]
    [Display(Name = "Popis")]
    [DataType(DataType.Text)]
    public string Popis { get; set; }
    
    [Required(ErrorMessage = "Zadejte počet hvězd")]
    [Display(Name = "Počet hvězd")]
    [Range(3,5, ErrorMessage = "Poče hvězd musí být mezi 3 a 5")]
    public int PocetHvezd { get; set; }
    
    [Required(ErrorMessage = "Zadejte adresu")]
    [Display(Name = "Adresa")]
    public AdresaModel Adresa { get; set; }
    
    [Required(ErrorMessage = "Zadejte obrázky")]
    [Display(Name = "Obrázky")]
    public ObrazkyUbytovaniModel[] ObrazkyUbytovani { get; set; }
}