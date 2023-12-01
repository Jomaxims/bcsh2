namespace app.Models;

public class UzivatelModel
{
    public required string Id { get; set; }

    [Required(ErrorMessage = "Zadejte přihlašovací jméno")]
    [Display(Name = "Přihlašovací jméno")]
    [DataType(DataType.Text)]
    public required string PrihlasovaciJmeno { get; set; }

    [Required(ErrorMessage = "Zadejte jméno")]
    [Display(Name = "Jméno")]
    [DataType(DataType.Text)]
    public required string Jmeno { get; set; }

    [Required(ErrorMessage = "Zadejte příjmení")]
    [Display(Name = "Příjmení")]
    [DataType(DataType.Text)]
    public required string Prijmeni { get; set; }

    [Required(ErrorMessage = "Zadejte roli")]
    [Display(Name = "Role")]
    [DataType(DataType.Text)]
    public required string Role { get; set; }
}