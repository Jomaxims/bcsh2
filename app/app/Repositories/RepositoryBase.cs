using app.DAL;
using app.Utils;

namespace app.Repositories;

public abstract class RepositoryBase
{
    protected readonly IDbUnitOfWork UnitOfWork;
    private readonly IIdConverter _idConverter;

    protected RepositoryBase(IDbUnitOfWork unitOfWork, IIdConverter idConverter)
    {
        UnitOfWork = unitOfWork;
        _idConverter = idConverter;
    }

    protected int DecodeId(string id) => _idConverter.Decode(id);
}