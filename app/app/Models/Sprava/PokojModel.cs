namespace app.Models.Sprava;

public class PokojModel
{
    public string PokojId { get; set; }
    
    [Required(ErrorMessage = "Zadejte počet míst")]
    [Display(Name = "Počet míst")]
    public int PocetMist { get; set; }
    
    [Required(ErrorMessage = "Zadejte název")]
    [Display(Name = "Název")]
    [DataType(DataType.Text)]
    public string Nazev { get; set; }
}