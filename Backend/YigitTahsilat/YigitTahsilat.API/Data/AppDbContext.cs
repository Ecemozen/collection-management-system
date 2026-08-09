using Microsoft.EntityFrameworkCore;
using YigitTahsilat.API.Entities;

namespace YigitTahsilat.API.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options)
            : base(options)
        {
        }

        public DbSet<User> Users { get; set; }

        public DbSet<Customer> Customers { get; set; }

        public DbSet<Debt> Debts { get; set; }

        public DbSet<Payment> Payments { get; set; }

        public DbSet<FeeType> FeeTypes { get; set; }

        public DbSet<Receipt> Receipts { get; set; }
    }
}