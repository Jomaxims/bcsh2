namespace app.Models.Sprava;

public class OsobaModel
{
    public string OsobaId { get; set; }
    
    [Required(ErrorMessage = "Zadejte jméno")]
    [Display(Name = "Jméno")]
    [DataType(DataType.Text)]
    public string Jmeno { get; set; }
    
    [Required(ErrorMessage = "Zadejte příjmení")]
    [Display(Name = "Příjmení")]
    [DataType(DataType.Text)]
    public string Prijmeni { get; set; }
    
    [Required(ErrorMessage = "Zadejte datum narození")]
    [Display(Name = "Datum narození")]
    [DataType(DataType.Date)]
    public DateOnly DatumNarozeni { get; set; }

    public override string ToString()
    {
        return $"{Jmeno} {Prijmeni}, {DatumNarozeni.ToString("d")}";
    }
}