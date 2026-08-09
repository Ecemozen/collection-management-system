using Microsoft.EntityFrameworkCore;
using YigitTahsilat.API.Data;
using YigitTahsilat.API.Entities;
using YigitTahsilat.API.Interfaces;

namespace YigitTahsilat.API.Repositories
{
    public class ReceiptRepository : IReceiptRepository
    {
        private readonly AppDbContext _context;

        public ReceiptRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<Receipt>> GetAllAsync()
        {
            return await _context.Receipts
                .Include(x => x.Payment)
                    .ThenInclude(x => x.Debt)
                        .ThenInclude(x => x.Customer)
                .Include(x => x.Payment)
                    .ThenInclude(x => x.FeeType)
                .ToListAsync();
        }

        public async Task<Receipt?> GetByIdAsync(int id)
        {
            return await _context.Receipts
                .Include(x => x.Payment)
                    .ThenInclude(x => x.Debt)
                        .ThenInclude(x => x.Customer)
                .Include(x => x.Payment)
                    .ThenInclude(x => x.FeeType)
                .FirstOrDefaultAsync(x => x.Id == id);
        }
       

        public async Task AddAsync(Receipt receipt)
        {
            try
            {
                await _context.Receipts.AddAsync(receipt);
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException ex)
            {
                Console.WriteLine("========== RECEIPT DB ERROR ==========");
                Console.WriteLine(ex.Message);
                Console.WriteLine(ex.InnerException?.Message);
                Console.WriteLine(ex.InnerException?.InnerException?.Message);
                Console.WriteLine("======================================");

                throw;
            }
        }

        public async Task UpdateAsync(Receipt receipt)
        {
            _context.Receipts.Update(receipt);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(Receipt receipt)
        {
            _context.Receipts.Remove(receipt);
            await _context.SaveChangesAsync();
        }

        public async Task<Receipt?> GetByPaymentIdAsync(int paymentId)
        {
            return await _context.Receipts
                .Include(x => x.Payment)
                    .ThenInclude(x => x.Debt)
                        .ThenInclude(x => x.Customer)
                .Include(x => x.Payment)
                    .ThenInclude(x => x.FeeType)
                .FirstOrDefaultAsync(x => x.PaymentId == paymentId);
        }
    }
}
