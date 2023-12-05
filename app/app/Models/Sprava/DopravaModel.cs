namespace app.Models.Sprava;

public class DopravaModel
{
    public string DopravaId { get; set; }

    [Required(ErrorMessage = "Zadejte název")]
    [Display(Name = "Název")]
    [DataType(DataType.Text)]
    public string Nazev { get; set; }
}