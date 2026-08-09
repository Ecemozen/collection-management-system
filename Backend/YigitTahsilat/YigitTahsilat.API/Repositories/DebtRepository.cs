using Microsoft.EntityFrameworkCore;
using YigitTahsilat.API.Data;
using YigitTahsilat.API.Entities;
using YigitTahsilat.API.Interfaces;
using YigitTahsilat.API.DTOs.Common;

namespace YigitTahsilat.API.Repositories
{
    public class DebtRepository : IDebtRepository
    {
        private readonly AppDbContext _context;

        public DebtRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<Debt>> GetAllAsync()
        {
            return await _context.Debts
                .Include(x => x.Customer)
                .ToListAsync();
        }

        public async Task<Debt?> GetByIdAsync(int id)
        {
            return await _context.Debts
                .Include(x => x.Customer)
                .FirstOrDefaultAsync(x => x.Id == id);
        }

        public async Task AddAsync(Debt debt)
        {
            await _context.Debts.AddAsync(debt);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(Debt debt)
        {
            _context.Debts.Update(debt);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(Debt debt)
        {
            _context.Debts.Remove(debt);
            await _context.SaveChangesAsync();
        }

        public async Task<List<Debt>> GetOverdueDebtsAsync()
        {
            return await _context.Debts
                .Include(x => x.Customer)
                .Where(x => x.DueDate < DateTime.Today &&
                            x.Status != "Ödendi")
                .ToListAsync();
        }

        public async Task<List<Debt>> SearchByCustomerNameAsync(string customerName)
        {
            return await _context.Debts
                .Include(x => x.Customer)
                .Where(x => x.Customer.CompanyName.Contains(customerName))
                .ToListAsync();
        }

        public async Task<List<Debt>> GetPagedAsync(PaginationParams paginationParams)
        {
            return await _context.Debts
                .Include(x => x.Customer)
                .Skip((paginationParams.PageNumber - 1) * paginationParams.PageSize)
                .Take(paginationParams.PageSize)
                .ToListAsync();
        }

        public async Task<List<Debt>> GetSortedAsync(string sortBy, bool desc)
        {
            var query = _context.Debts
                .Include(x => x.Customer)
                .AsQueryable();

            switch (sortBy.ToLower())
            {
                case "amount":
                    query = desc
                        ? query.OrderByDescending(x => x.Amount)
                        : query.OrderBy(x => x.Amount);
                    break;

                case "duedate":
                    query = desc
                        ? query.OrderByDescending(x => x.DueDate)
                        : query.OrderBy(x => x.DueDate);
                    break;

                case "companyname":
                    query = desc
                        ? query.OrderByDescending(x => x.Customer.CompanyName)
                        : query.OrderBy(x => x.Customer.CompanyName);
                    break;

                default:
                    query = query.OrderBy(x => x.Id);
                    break;
            }

            return await query.ToListAsync();
        }

        public async Task<List<Debt>> GetFilteredAsync(DebtFilterParams filterParams)
        {
            var query = _context.Debts
                .Include(x => x.Customer)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(filterParams.Status))
            {
                query = query.Where(x => x.Status == filterParams.Status);
            }

            if (filterParams.MinAmount.HasValue)
            {
                query = query.Where(x => x.Amount >= filterParams.MinAmount.Value);
            }

            if (filterParams.MaxAmount.HasValue)
            {
                query = query.Where(x => x.Amount <= filterParams.MaxAmount.Value);
            }

            if (filterParams.StartDate.HasValue)
            {
                query = query.Where(x => x.DueDate >= filterParams.StartDate.Value);
            }

            if (filterParams.EndDate.HasValue)
            {
                query = query.Where(x => x.DueDate <= filterParams.EndDate.Value);
            }

            return await query.ToListAsync();
        }
    }
}