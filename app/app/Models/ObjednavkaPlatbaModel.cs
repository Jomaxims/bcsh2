namespace app.Models;

public class ObjednavkaPlatbaModel
{
    [Required(ErrorMessage = "Zadejte číslo karty")]
    [Display(Name = "Číslo karty")]
    [DataType(DataType.CreditCard)]
    public required string CisloKarty { get; set; }
    
    [Required(ErrorMessage = "Zadejte datum platnosti")]
    [Display(Name = "Datum platnosti")]
    public required string DatumPlatnosti { get; set; }
    
    [Required(ErrorMessage = "Zadejte CVV")]
    [Display(Name = "CVV")]
    public required string Cvv { get; set; }
}