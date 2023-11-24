namespace app.Models;

public class ObjednavkaModel : NakupModel
{
    public string ObjednavkaId { get; set; }
    public bool Zaplacena { get; set; }
}