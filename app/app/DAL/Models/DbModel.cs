using System.ComponentModel.DataAnnotations;
using System.Reflection;

namespace app.DAL.Models;

public abstract class DbModel
{
    [Key]
    public int? Id { get; init; }
}