namespace app.Models.Sprava;

public class PlatbaModel
{
    public string PlatbaId { get; set; }

    [Required(ErrorMessage = "Zadejte částku")]
    [Display(Name = "Částka (Kč)")]
    [Range(1, int.MaxValue, ErrorMessage = "Částka musí být minimálně 1")]
    public double Castka { get; set; }

    [Required(ErrorMessage = "Zadejte číslo účtu")]
    [Display(Name = "Číslo účtu")]
    [DataType(DataType.Text)]
    public string? CisloUctu { get; set; }

    [Required(ErrorMessage = "Zadejte stav")]
    [Display(Name = "Zaplacena")]
    public bool Zaplacena { get; set; }
}