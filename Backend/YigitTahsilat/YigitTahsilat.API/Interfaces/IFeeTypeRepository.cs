using YigitTahsilat.API.Entities;

namespace YigitTahsilat.API.Interfaces
{
    public interface IFeeTypeRepository
    {
        Task<List<FeeType>> GetAllAsync();

        Task<FeeType?> GetByIdAsync(int id);

        Task AddAsync(FeeType feeType);

        Task UpdateAsync(FeeType feeType);

        Task DeleteAsync(FeeType feeType);
    }
}