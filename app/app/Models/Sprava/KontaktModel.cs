namespace app.Models.Sprava;

public class KontaktModel
{
    public string KontaktId { get; set; }

    [Required(ErrorMessage = "Zadejte email")]
    [Display(Name = "Email")]
    [DataType(DataType.EmailAddress, ErrorMessage = "Zadejte platný email")]
    public string Email { get; set; }

    [Required(ErrorMessage = "Zadejte telefon")]
    [Display(Name = "Telefon")]
    [DataType(DataType.PhoneNumber)]
    public string Telefon { get; set; }
}