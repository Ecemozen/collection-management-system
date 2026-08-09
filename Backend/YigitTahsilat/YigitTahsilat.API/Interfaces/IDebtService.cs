using YigitTahsilat.API.DTOs.Debt;
using YigitTahsilat.API.DTOs.Common;


namespace YigitTahsilat.API.Interfaces
{
    public interface IDebtService
    {
        Task<List<DebtDto>> GetAllAsync();

        Task<DebtDto?> GetByIdAsync(int id);

        Task<DebtDto> AddAsync(CreateDebtDto dto);

        Task UpdateAsync(int id, UpdateDebtDto dto);

        Task DeleteAsync(int id);

        Task<List<DebtDto>> GetOverdueDebtsAsync();

        Task<List<DebtDto>> SearchByCustomerNameAsync(string customerName);

        Task<List<DebtDto>> GetPagedAsync(PaginationParams paginationParams);

        Task<List<DebtDto>> GetSortedAsync(string sortBy, bool desc);

        Task<List<DebtDto>> GetFilteredAsync(DebtFilterParams filterParams);

        
    }
}