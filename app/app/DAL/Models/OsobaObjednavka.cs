namespace app.DAL.Models;

public class OsobaObjednavka : IDbModel
{
    public int OsobaId { get; set; }
    public int ObjednavkaId { get; set; }
}