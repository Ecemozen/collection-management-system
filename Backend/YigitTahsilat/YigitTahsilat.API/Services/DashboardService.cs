using Microsoft.EntityFrameworkCore;
using YigitTahsilat.API.Data;
using YigitTahsilat.API.DTOs.Dashboard;
using YigitTahsilat.API.Interfaces;

namespace YigitTahsilat.API.Services
{
    public class DashboardService : IDashboardService
    {
        private readonly AppDbContext _context;

        public DashboardService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<DashboardDto> GetDashboardAsync()
        {
            var totalCustomers = await _context.Customers.CountAsync();

            var totalDebtAmount = await _context.Debts.SumAsync(x => x.Amount);

            var remainingAmount = await _context.Debts.SumAsync(x => x.RemainingAmount);

            var overdueDebtCount = await _context.Debts
                .CountAsync(x => x.DueDate < DateTime.Today &&
                                 x.Status != "Ödendi");

            var pendingDebtCount = await _context.Debts
                .CountAsync(x => x.Status == "Bekliyor");

            var paidDebtCount = await _context.Debts
                .CountAsync(x => x.Status == "Ödendi");

            return new DashboardDto
            {
                TotalCustomers = totalCustomers,
                TotalDebtAmount = totalDebtAmount,
                TotalCollectedAmount = totalDebtAmount - remainingAmount,
                RemainingAmount = remainingAmount,
                OverdueDebtCount = overdueDebtCount,
                PendingDebtCount = pendingDebtCount,
                PaidDebtCount = paidDebtCount
            };
        }
    }
}
