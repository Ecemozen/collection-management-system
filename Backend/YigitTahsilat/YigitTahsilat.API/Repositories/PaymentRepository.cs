using Microsoft.EntityFrameworkCore;
using YigitTahsilat.API.Data;
using YigitTahsilat.API.Entities;
using YigitTahsilat.API.Interfaces;

namespace YigitTahsilat.API.Repositories
{
    public class PaymentRepository : IPaymentRepository
    {
        private readonly AppDbContext _context;

        public PaymentRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<Payment>> GetAllAsync()
        {
            return await _context.Payments
                .Include(p => p.Debt)
                    .ThenInclude(d => d.Customer)
                .Include(p => p.FeeType)
                .Include(p => p.Receipt)
                .ToListAsync();
        }

        public async Task<Payment?> GetByIdAsync(int id)
        {
            return await _context.Payments
                .Include(p => p.Debt)
                    .ThenInclude(d => d.Customer)
                .Include(p => p.FeeType)
                .Include(p => p.Receipt)
                .FirstOrDefaultAsync(p => p.Id == id);
        }

        public async Task AddAsync(Payment payment)
        {
            await _context.Payments.AddAsync(payment);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(Payment payment)
        {
            _context.Payments.Update(payment);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(Payment payment)
        {
            _context.Payments.Remove(payment);
            await _context.SaveChangesAsync();
        }

        public async Task<List<Payment>> GetByDebtIdAsync(int debtId)
        {
            return await _context.Payments
                .Where(p => p.DebtId == debtId)
                .Include(p => p.FeeType)
                .Include(p => p.Receipt)
                .ToListAsync();
        }
    }
}