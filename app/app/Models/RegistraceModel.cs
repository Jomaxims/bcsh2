namespace app.Models;

public class Over18Attribute : ValidationAttribute
{
    public override bool IsValid(object? value)
    {
        if (value == null)
            return false;

        var date = (DateOnly)value;
        var today = DateTime.Today;
        var maxDate = new DateOnly(today.Year - 18, today.Month, today.Day);

        return maxDate.CompareTo(date) > 0;
    }
}

public class RegistraceModel
{
    [Required(ErrorMessage = "Zadejte přihlašovací jméno")]
    [Display(Name = "Přihlašovací jméno")]
    [DataType(DataType.Text)]
    public required string PrihlasovaciJmeno { get; set; }
    
    [Required(ErrorMessage = "Zadejte heslo")]
    [Display(Name = "Heslo")]
    [DataType(DataType.Password)]
    [MinLength(5, ErrorMessage = "Heslo musí mít minimálně 5 znaků")]
    public required string Heslo { get; set; }
    
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
    // [DisplayFormat(DataFormatString = "{0:dd.MM.yyyy}", ApplyFormatInEditMode = true)]
    [Over18(ErrorMessage = "Zákazník musí být starší 18 let")]
    public required DateOnly DatumNarozeni { get; set; }
    
    [Required(ErrorMessage = "Zadejte kontakt")]
    [Display(Name = "Kontakt")]
    public required KontaktModel Kontakt { get; set; }
    
    [Required(ErrorMessage = "Zadejte adresu")]
    [Display(Name = "Adresa")]
    public required AdresaModel Adresa { get; set; }
}

public class AdresaModel
{
    [Required(ErrorMessage = "Zadejte ulici")]
    [Display(Name = "Ulice")]
    [DataType(DataType.Text)]
    public required string Ulice { get; set; }
    
    [Required(ErrorMessage = "Zadejte číslo popisné")]
    [Display(Name = "Číslo popisné")]
    [DataType(DataType.Text)]
    public required string CisloPopisne { get; set; }
    
    [Required(ErrorMessage = "Zadejte město")]
    [Display(Name = "Město")]
    [DataType(DataType.Text)]
    public required string Mesto { get; set; }
    
    [Required(ErrorMessage = "Zadejte PSČ")]
    [Display(Name = "PSČ")]
    [DataType(DataType.Text)]
    public required string PSC { get; set; }
    
    [Display(Name = "Poznámka")]
    [DataType(DataType.Text)]
    public string? Poznamka { get; set; }
}

public class KontaktModel
{
    [Required(ErrorMessage = "Zadejte email")]
    [Display(Name = "Email")]
    [DataType(DataType.EmailAddress, ErrorMessage = "Zadejte platný email")]
    public required string Email { get; set; }
    
    [Required(ErrorMessage = "Zadejte telefon")]
    [Display(Name = "Telefon")]
    [DataType(DataType.PhoneNumber)]
    public required string Telefon { get; set; }
}