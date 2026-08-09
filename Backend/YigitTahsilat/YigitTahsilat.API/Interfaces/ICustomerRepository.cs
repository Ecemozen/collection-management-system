using YigitTahsilat.API.Entities;

namespace YigitTahsilat.API.Interfaces
{
    public interface ICustomerRepository
    {
        Task<List<Customer>> GetAllAsync();

        Task<Customer?> GetByIdAsync(int id);

        Task<Customer> AddAsync(Customer customer);

        Task UpdateAsync(Customer customer);

        Task DeleteAsync(Customer customer);
    }
}