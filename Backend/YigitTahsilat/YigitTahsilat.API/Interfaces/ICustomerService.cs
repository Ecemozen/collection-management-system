using YigitTahsilat.API.DTOs.Customer;

namespace YigitTahsilat.API.Interfaces
{
    public interface ICustomerService
    {
        Task<List<CustomerListDto>> GetAllAsync();

        Task<CustomerDto?> GetByIdAsync(int id);

        Task<CustomerDto> AddAsync(CreateCustomerDto dto);

        Task UpdateAsync(int id, UpdateCustomerDto dto);

        Task DeleteAsync(int id);
    }
}