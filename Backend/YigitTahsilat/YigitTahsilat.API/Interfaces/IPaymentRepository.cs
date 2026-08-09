using YigitTahsilat.API.Entities;

namespace YigitTahsilat.API.Interfaces
{
    public interface IPaymentRepository
    {
        Task<List<Payment>> GetAllAsync();

        Task<Payment?> GetByIdAsync(int id);

        Task AddAsync(Payment payment);

        Task UpdateAsync(Payment payment);

        Task DeleteAsync(Payment payment);

        Task<List<Payment>> GetByDebtIdAsync(int debtId);
    }
}