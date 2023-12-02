using Sqids;

namespace app.Utils;

public class InvalidIdException : Exception
{
    public InvalidIdException(string? message) : base(message)
    {
    }
}

public interface IIdConverter
{
    string Encode(int id);
    string Encode(string id);
    int Decode(string id);
}

/// <summary>
/// Třída pro kódování a dekódování id
/// </summary>
public class IdConverter : IIdConverter
{
    private readonly SqidsEncoder<int> _encoder;

    public IdConverter(SqidsEncoder<int> encoder)
    {
        _encoder = encoder;
    }

    public string Encode(int id)
    {
        return _encoder.Encode(id);
    }

    public string Encode(string id)
    {
        return _encoder.Encode(int.Parse(id));
    }

    public int Decode(string id)
    {
        var res = _encoder.Decode(id);

        if (res.Count == 0)
            throw new InvalidIdException($"Neplatné ID {id}");

        return res[0];
    }
}