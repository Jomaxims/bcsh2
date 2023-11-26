namespace app.Models.Sprava;

public class StatModel
{
    public string StatId { get; set; }
    
    [Required(ErrorMessage = "Zadejte zkratku")]
    [Display(Name = "Zkratka")]
    [DataType(DataType.Text)]
    [MaxLength(3, ErrorMessage = "Zkratka státu musí mít 3 znaky")]
    [MinLength(3, ErrorMessage = "Zkratka státu musí mít 3 znaky")]
    public string Zkratka { get; set; }
    
    [Required(ErrorMessage = "Zadejte název")]
    [Display(Name = "Název")]
    [DataType(DataType.Text)]
    public string Nazev { get; set; }
}