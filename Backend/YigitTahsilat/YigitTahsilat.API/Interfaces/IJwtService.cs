using YigitTahsilat.API.Entities;

namespace YigitTahsilat.API.Interfaces
{
    public interface IJwtService
    {
        string GenerateToken(User user);
    }
}