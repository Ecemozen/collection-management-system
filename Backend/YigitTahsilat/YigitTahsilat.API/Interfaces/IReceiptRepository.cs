using YigitTahsilat.API.Entities;

namespace YigitTahsilat.API.Interfaces
{
    public interface IReceiptRepository
    {
        Task<List<Receipt>> GetAllAsync();

        Task<Receipt?> GetByIdAsync(int id);

        Task<Receipt?> GetByPaymentIdAsync(int paymentId);

        Task AddAsync(Receipt receipt);

        Task UpdateAsync(Receipt receipt);

        Task DeleteAsync(Receipt receipt);
    }
}