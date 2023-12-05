namespace app.Models;

public class LoginModel
{
    [Required(ErrorMessage = "Zadejte jméno")]
    [Display(Name = "Jméno")]
    [DataType(DataType.Text)]
    public required string Jmeno { get; set; }

    [Required(ErrorMessage = "Zadejte heslo")]
    [Display(Name = "Heslo")]
    [DataType(DataType.Password)]
    public required string Heslo { get; set; }
}