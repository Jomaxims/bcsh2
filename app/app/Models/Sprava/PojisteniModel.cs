namespace app.Models.Sprava;

public class PojisteniModel
{
    public string PojisteniId { get; set; }

    [Required(ErrorMessage = "Zadejte cenu za den")]
    [Display(Name = "Cena za den")]
    [Range(0, int.MaxValue, ErrorMessage = "Pojištění může stát nejméně 0 Kč")]
    public double CenaZaDen { get; set; }

    [Required(ErrorMessage = "Zadejte název")]
    [Display(Name = "Název")]
    [DataType(DataType.Text)]
    public string Nazev { get; set; }
}