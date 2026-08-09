using Microsoft.EntityFrameworkCore;
using YigitTahsilat.API.Data;
using YigitTahsilat.API.Entities;
using YigitTahsilat.API.Interfaces;

namespace YigitTahsilat.API.Repositories
{
    public class UserRepository : IUserRepository
    {
        private readonly AppDbContext _context;

        public UserRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<User?> GetByEmailAsync(string email)
        {
            return await _context.Users
                .FirstOrDefaultAsync(x => x.Email == email);
        }
    }
}