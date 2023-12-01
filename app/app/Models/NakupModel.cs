namespace app.Models;

public class NakupModel
{
    public required ZajezdNakupModel Zajezd { get; set; }
    public required Sprava.OsobaModel[] Osoby { get; set; }
}

public class OsobaModel
{
    [Required(ErrorMessage = "Zadejte jméno")]
    [Display(Name = "Jméno")]
    [DataType(DataType.Text)]
    public required string Jmeno { get; set; }

    [Required(ErrorMessage = "Zadejte příjmení")]
    [Display(Name = "Příjmení")]
    [DataType(DataType.Text)]
    public required string Prijmeni { get; set; }

    [Required(ErrorMessage = "Zadejte datum narození")]
    [Display(Name = "Datum narození")]
    [DataType(DataType.Date)]
    [Over18(ErrorMessage = "Zákazník musí být starší 18 let")]
    public required DateOnly DatumNarozeni { get; set; }
}