using app.DAL;
using app.DAL.Models;
using app.Models.Sprava;
using app.Utils;

namespace app.Repositories;

public class AdresaRepository : BaseRepository
{
    private readonly GenericDao<Adresa> _adresaDao;

    public AdresaRepository(
        ILogger<AdresaRepository> logger,
        IDbUnitOfWork unitOfWork,
        IIdConverter idConverter,
        GenericDao<Adresa> adresaDao
    ) : base(logger, unitOfWork, idConverter)
    {
        _adresaDao = adresaDao;
    }

    public int AddOrEdit(AdresaModel model)
    {
        return AddOrEdit(_adresaDao, model, MapToDto);
    }

    public void Delete(int id)
    {
        Delete(_adresaDao, id);
    }

    private Adresa MapToDto(AdresaModel model)
    {
        return new Adresa
        {
            AdresaId = DecodeId(model.AdresaId),
            Mesto = model.Mesto,
            Psc = model.Psc,
            Ulice = model.Ulice,
            CisloPopisne = model.CisloPopisne,
            Poznamka = model.Poznamka,
            StatId = DecodeId(model.Stat?.StatId) ?? -1
        };
    }
}