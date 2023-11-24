namespace app.Models.Sprava;

public class KontaktModel
{
    public required string KontaktId { get; set; }
    
    [Required(ErrorMessage = "Zadejte email")]
    [Display(Name = "Email")]
    [DataType(DataType.EmailAddress, ErrorMessage = "Zadejte platný email")]
    public required string Email { get; set; }
    
    [Required(ErrorMessage = "Zadejte telefon")]
    [Display(Name = "Telefon")]
    [DataType(DataType.PhoneNumber)]
    public required string Telefon { get; set; }
}