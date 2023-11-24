namespace app.Models.Sprava;

public class ZamestnanecModel
{
    public string ZamestnanecId { get; set; }
    
    [Required(ErrorMessage = "Zadejte přihlašovací údaje")]
    [Display(Name = "Přihlašovací údaje")]
    public PrihlasovaciUdajeModel PrihlasovaciUdaje { get; set; }
    
    [Required(ErrorMessage = "Zadejte jméno")]
    [Display(Name = "Jméno")]
    [DataType(DataType.Text)]
    public string Jmeno { get; set; }
    
    [Required(ErrorMessage = "Zadejte příjmení")]
    [Display(Name = "Příjmení")]
    [DataType(DataType.Text)]
    public string Prijmeni { get; set; }
    
    [Required(ErrorMessage = "Zadejte roli")]
    [Display(Name = "Role")]
    public RoleModel Role { get; set; }
    
    [Display(Name = "Nadřízený")]
    [DataType(DataType.Text)]
    public ZamestnanecModel? Nadrizeny { get; set; }
}