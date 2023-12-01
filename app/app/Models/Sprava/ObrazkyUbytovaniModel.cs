namespace app.Models.Sprava;

public class ObrazkyUbytovaniModel
{
    public string ObrazkyUbytovaniId { get; set; }
    public byte[] Obrazek { get; set; }

    [Required(ErrorMessage = "Zadejte název")]
    [Display(Name = "Název")]
    [DataType(DataType.Text)]
    public string Nazev { get; set; }
}