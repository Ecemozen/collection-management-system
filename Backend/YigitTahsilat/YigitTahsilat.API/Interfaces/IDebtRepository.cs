using YigitTahsilat.API.Entities;
using YigitTahsilat.API.DTOs.Common;

namespace YigitTahsilat.API.Interfaces
{
    public interface IDebtRepository
    {
        Task<List<Debt>> GetAllAsync();

        Task<Debt?> GetByIdAsync(int id);

        Task AddAsync(Debt debt);

        Task UpdateAsync(Debt debt);

        Task DeleteAsync(Debt debt);

        Task<List<Debt>> GetOverdueDebtsAsync();
        Task<List<Debt>> SearchByCustomerNameAsync(string customerName);

        Task<List<Debt>> GetPagedAsync(PaginationParams paginationParams);

        Task<List<Debt>> GetSortedAsync(string sortBy, bool desc);

        Task<List<Debt>> GetFilteredAsync(DebtFilterParams filterParams);
    }
}
