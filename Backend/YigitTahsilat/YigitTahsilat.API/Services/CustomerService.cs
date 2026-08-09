using AutoMapper;
using YigitTahsilat.API.DTOs.Customer;
using YigitTahsilat.API.Entities;
using YigitTahsilat.API.Interfaces;

namespace YigitTahsilat.API.Services
{
    public class CustomerService : ICustomerService
    {
        private readonly ICustomerRepository _repository;
        private readonly IMapper _mapper;

        public CustomerService(ICustomerRepository repository, IMapper mapper)
        {
            _repository = repository;
            _mapper = mapper;
        }
        public async Task<List<CustomerListDto>> GetAllAsync()
        {
            var customers = await _repository.GetAllAsync();

            return customers.Select(customer => new CustomerListDto
            {
                Id = customer.Id,
                CustomerCode = customer.CustomerCode,
                CompanyName = customer.CompanyName,
                AuthorizedPerson = customer.AuthorizedPerson,
                Phone = customer.Phone,
                Balance = customer.Debts.Sum(d => d.RemainingAmount),
                IsActive = customer.IsActive
            }).ToList();
        }

        public async Task<CustomerDto?> GetByIdAsync(int id)
        {
            var customer = await _repository.GetByIdAsync(id);

            if (customer == null)
                return null;

            var payments = customer.Debts
                .SelectMany(d => d.Payments)
                .OrderByDescending(p => p.PaymentDate)
                .ToList();

            return new CustomerDto
            {
                Id = customer.Id,
                CustomerCode = customer.CustomerCode,
                CompanyName = customer.CompanyName,
                AuthorizedPerson = customer.AuthorizedPerson,
                Phone = customer.Phone,
                Email = customer.Email,
                Address = customer.Address,
                TaxOffice = customer.TaxOffice,
                TaxNumber = customer.TaxNumber,
                IsActive = customer.IsActive,

                Balance = customer.Debts.Sum(d => d.RemainingAmount),

                TotalCollected = payments
                    .Where(p => p.IsPaid)
                    .Sum(p => p.Amount),

                PendingCollection = customer.Debts
                    .Where(d => d.RemainingAmount > 0)
                    .Sum(d => d.RemainingAmount),

                Payments = payments
                    .Take(10)
                    .Select(p => new CustomerPaymentDto
                    {
                        PaymentDate = p.PaymentDate,
                        Amount = p.Amount,
                        IsPaid = p.IsPaid
                    })
                    .ToList()
            };
        }

        public async Task<CustomerDto> AddAsync(CreateCustomerDto dto)
        {
            var customer = _mapper.Map<Customer>(dto);

            customer.CustomerCode = $"CUST-{Guid.NewGuid().ToString("N")[..8].ToUpper()}";

            await _repository.AddAsync(customer);

            return _mapper.Map<CustomerDto>(customer);
        }

        public async Task UpdateAsync(int id, UpdateCustomerDto dto)
        {
            var customer = await _repository.GetByIdAsync(id);

            if (customer == null)
                throw new Exception("Customer not found.");

            _mapper.Map(dto, customer);

            await _repository.UpdateAsync(customer);
        }

        public async Task DeleteAsync(int id)
        {
            var customer = await _repository.GetByIdAsync(id);

            if (customer == null)
                throw new Exception("Customer not found.");

            await _repository.DeleteAsync(customer);
        }
    }
}