using Microsoft.EntityFrameworkCore;
using YigitTahsilat.API.Data;
using YigitTahsilat.API.Entities;
using YigitTahsilat.API.Interfaces;

namespace YigitTahsilat.API.Repositories
{
    public class CustomerRepository : ICustomerRepository
    {
        private readonly AppDbContext _context;

        public CustomerRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<Customer>> GetAllAsync()
        {
            return await _context.Customers
                .Include(x => x.Debts)
                .ToListAsync();
        }
        public async Task<Customer?> GetByIdAsync(int id)
        {
            return await _context.Customers
                .Include(x => x.Debts)
                    .ThenInclude(d => d.Payments)
                .FirstOrDefaultAsync(x => x.Id == id);
        }

        public async Task<Customer> AddAsync(Customer customer)
        {
            _context.Customers.Add(customer);
            await _context.SaveChangesAsync();

            return customer;
        }

        public async Task UpdateAsync(Customer customer)
        {
            _context.Customers.Update(customer);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(Customer customer)
        {
            _context.Customers.Remove(customer);
            await _context.SaveChangesAsync();
        }
    }
}
