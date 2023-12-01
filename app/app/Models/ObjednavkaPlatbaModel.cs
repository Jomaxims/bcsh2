namespace app.Models;

public class ObjednavkaPlatbaModel
{
    public required string PlatbaId { get; set; }

    [Required(ErrorMessage = "Zadejte číslo karty")]
    [Display(Name = "Číslo karty")]
    [DataType(DataType.CreditCard)]
    [MinLength(16, ErrorMessage = "Zadejte 16 znaků")]
    [MaxLength(16, ErrorMessage = "Zadejte 16 znaků")]
    public required string CisloKarty { get; set; }

    [Required(ErrorMessage = "Zadejte datum platnosti")]
    [Display(Name = "Datum platnosti")]
    [MinLength(5, ErrorMessage = "Zadejte 5 znaků")]
    [MaxLength(5, ErrorMessage = "Zadejte 5 znaků")]
    public required string DatumPlatnosti { get; set; }

    [Required(ErrorMessage = "Zadejte CVV")]
    [Display(Name = "CVV")]
    [MinLength(3, ErrorMessage = "Zadejte 3 znaky")]
    [MaxLength(3, ErrorMessage = "Zadejte 3 znaky")]
    public required string Cvv { get; set; }
}