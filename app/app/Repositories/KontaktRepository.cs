using System.Transactions;
using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;
using Dapper;

namespace app.Repositories;

public class KontaktRepository : BaseRepository
{
    private readonly GenericDao<Kontakt> _kontaktDao;

    public KontaktRepository(
        ILogger<KontaktRepository> logger,
        IDbUnitOfWork unitOfWork,
        IIdConverter idConverter,
        GenericDao<Kontakt> kontaktDao
    ) : base(logger, unitOfWork, idConverter)
    {
        _kontaktDao = kontaktDao;
    }

    public int AddOrEdit(KontaktModel model) => AddOrEdit(_kontaktDao, model, MapToDto);

    public void Delete(int id) => Delete(_kontaktDao, id);

    public KontaktModel Get(int id) => Get(_kontaktDao, id, MapToModel);

    public IEnumerable<KontaktModel> GetAll() => GetAll(_kontaktDao, MapToModel);

    private KontaktModel MapToModel(Kontakt dto) => new()
    {
        KontaktId = EncodeId(dto.KontaktId),
        Email = dto.Email,
        Telefon = dto.Telefon
    };
    
    private Kontakt MapToDto(KontaktModel model) => new()
    {
        KontaktId = DecodeId(model.KontaktId),
        Email = model.Email,
        Telefon = model.Telefon
    };
}