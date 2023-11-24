namespace app.Models.Sprava;

public class StatModel
{
    public string StatId { get; set; }
    
    [Required(ErrorMessage = "Zadejte zkratku")]
    [Display(Name = "Zkratka")]
    [DataType(DataType.Text)]
    public string Zkratka { get; set; }
    
    [Required(ErrorMessage = "Zadejte název")]
    [Display(Name = "Název")]
    [DataType(DataType.Text)]
    public string Nazev { get; set; }
}