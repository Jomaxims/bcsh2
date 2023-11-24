namespace app.Models.Sprava;

public class PrihlasovaciUdajeModel
{
    public string PrihlasovaciUdajeId { get; set; }
    
    [Required(ErrorMessage = "Zadejte jméno")]
    [Display(Name = "Jméno")]
    [DataType(DataType.Text)]
    public string Jmeno { get; set; }
    
    [Required(ErrorMessage = "Zadejte heslo")]
    [Display(Name = "Heslo")]
    [DataType(DataType.Password)]
    [MinLength(5, ErrorMessage = "Heslo musí mít minimálně 5 znaků")]
    public string Heslo { get; set; }
}