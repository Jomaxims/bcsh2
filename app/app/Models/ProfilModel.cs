namespace app.Models;

public class ProfilModel
{
    public class ZajezdModel
    {
        public required string Id { get; set; }
        public required string Nazev { get; set; }
        public required int PocetHvezd { get; set; }
        public required DateOnly Od { get; set; }
        public required DateOnly Do { get; set; }
        public required double Cena { get; set; }
        public required bool Zaplaceno { get; set; }
        public required string PlatbaId { get; set; }
    }

    public required string PrihlasovaciJmeno { get; set; }

    public required UzivatelUdaje Udaje { get; set; }

    public required IEnumerable<ZajezdModel> Zajezdy { get; set; }
}

public class UzivatelUdaje
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
    
    [Required(ErrorMessage = "Zadejte kontakt")]
    [Display(Name = "Kontakt")]
    public required KontaktModel Kontakt { get; set; }
    
    [Required(ErrorMessage = "Zadejte adresu")]
    [Display(Name = "Adresa")]
    public required AdresaModel Adresa { get; set; }
}