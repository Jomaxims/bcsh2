using app.Models.Sprava;

namespace app.Models;

public class ProfilModel
{
    public required ZakaznikModel Zakaznik { get; set; }

    public required IEnumerable<app.Models.Sprava.ObjednavkaModel> Objednavky { get; set; }
}