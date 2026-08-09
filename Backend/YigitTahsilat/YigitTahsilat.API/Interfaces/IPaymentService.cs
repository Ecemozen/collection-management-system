using YigitTahsilat.API.DTOs.Payment;

namespace YigitTahsilat.API.Interfaces
{
    public interface IPaymentService
    {
        Task<List<PaymentDto>> GetAllAsync();

        Task<PaymentDto?> GetByIdAsync(int id);

        Task<PaymentDto> AddAsync(CreatePaymentDto dto);

        Task<bool> UpdateAsync(int id, UpdatePaymentDto dto);

        Task<bool> DeleteAsync(int id);
    }
}