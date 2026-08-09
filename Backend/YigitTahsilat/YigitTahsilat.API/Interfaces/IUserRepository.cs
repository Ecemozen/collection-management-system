using YigitTahsilat.API.Entities;

namespace YigitTahsilat.API.Interfaces
{
    public interface IUserRepository
    {
        Task<User?> GetByEmailAsync(string email);
    }
}