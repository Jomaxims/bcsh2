namespace app.Models;

public class ZajezdNakupModel
{
    [Required(ErrorMessage = "Zadejte termín")]
    [Display(Name = "Termín")]
    public required string Termin { get; set; }
    
    [Required(ErrorMessage = "Zadejte počet osob")]
    [Display(Name = "Počet osob")]
    public required int PocetOsob { get; set; }
    
    [Required(ErrorMessage = "Zadejte pojištění")]
    [Display(Name = "Pojištění")]
    public required string Pojisteni { get; set; }
    
    [Required(ErrorMessage = "Zadejte pokoj")]
    [Display(Name = "Pokoj")]
    public required string Pokoj { get; set; }
}