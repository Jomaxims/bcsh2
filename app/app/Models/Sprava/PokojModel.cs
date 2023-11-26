namespace app.Models.Sprava;

public class PokojModel
{
    public string PokojId { get; set; }
    
    [Required(ErrorMessage = "Zadejte počet míst")]
    [Display(Name = "Počet míst")]
    [Range(1, int.MaxValue, ErrorMessage = "Pokoj musí mít alespoň 1 místo")]
    public int PocetMist { get; set; }
    
    [Required(ErrorMessage = "Zadejte název")]
    [Display(Name = "Název")]
    [DataType(DataType.Text)]
    public string Nazev { get; set; }
}