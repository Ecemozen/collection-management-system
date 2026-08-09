using Microsoft.EntityFrameworkCore;
using YigitTahsilat.API.Data;
using YigitTahsilat.API.Entities;
using YigitTahsilat.API.Interfaces;

namespace YigitTahsilat.API.Repositories
{
    public class FeeTypeRepository : IFeeTypeRepository
    {
        private readonly AppDbContext _context;

        public FeeTypeRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<FeeType>> GetAllAsync()
        {
            return await _context.FeeTypes.ToListAsync();
        }

        public async Task<FeeType?> GetByIdAsync(int id)
        {
            return await _context.FeeTypes.FirstOrDefaultAsync(x => x.Id == id);
        }

        public async Task AddAsync(FeeType feeType)
        {
            await _context.FeeTypes.AddAsync(feeType);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(FeeType feeType)
        {
            _context.FeeTypes.Update(feeType);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(FeeType feeType)
        {
            _context.FeeTypes.Remove(feeType);
            await _context.SaveChangesAsync();
        }
    }
}
