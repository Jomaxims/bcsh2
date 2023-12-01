namespace app.Models.Sprava;

public class AdresaModel
{
    public string AdresaId { get; set; }

    [Required(ErrorMessage = "Zadejte ulici")]
    [Display(Name = "Ulice")]
    [DataType(DataType.Text)]
    public string Ulice { get; set; }

    [Required(ErrorMessage = "Zadejte číslo popisné")]
    [Display(Name = "Číslo popisné")]
    [DataType(DataType.Text)]
    public string CisloPopisne { get; set; }

    [Required(ErrorMessage = "Zadejte město")]
    [Display(Name = "Město")]
    [DataType(DataType.Text)]
    public string Mesto { get; set; }

    [Required(ErrorMessage = "Zadejte PSČ")]
    [Display(Name = "PSČ")]
    [DataType(DataType.Text)]
    public string Psc { get; set; }

    [Display(Name = "Poznámka k adrese")]
    [DataType(DataType.Text)]
    public string? Poznamka { get; set; }

    [Required(ErrorMessage = "Zadejte stát")]
    [Display(Name = "Stát")]
    public StatModel? Stat { get; set; }

    public override string ToString()
    {
        return $"{Ulice} {CisloPopisne}, {Mesto} {Psc}" + (Stat == null ? "" : $", {Stat.Nazev}");
    }
}