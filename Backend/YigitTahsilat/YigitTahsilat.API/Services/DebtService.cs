using AutoMapper;
using YigitTahsilat.API.DTOs.Debt;
using YigitTahsilat.API.Entities;
using YigitTahsilat.API.Interfaces;
using YigitTahsilat.API.DTOs.Common;


namespace YigitTahsilat.API.Services
{
    public class DebtService : IDebtService
    {
        private readonly IDebtRepository _debtRepository;
        private readonly IMapper _mapper;

        public DebtService(
            IDebtRepository debtRepository,
            IMapper mapper)
        {
            _debtRepository = debtRepository;
            _mapper = mapper;
        }

        public async Task<List<DebtDto>> GetAllAsync()
        {
            var debts = await _debtRepository.GetAllAsync();

            return _mapper.Map<List<DebtDto>>(debts);
        }

        public async Task<DebtDto?> GetByIdAsync(int id)
        {
            var debt = await _debtRepository.GetByIdAsync(id);

            if (debt == null)
                return null;

            return _mapper.Map<DebtDto>(debt);
        }

        public async Task<DebtDto> AddAsync(CreateDebtDto dto)
        {
            var debt = _mapper.Map<Debt>(dto);

            debt.RemainingAmount = dto.Amount;
            debt.Status = "Bekliyor";

            await _debtRepository.AddAsync(debt);

            return _mapper.Map<DebtDto>(debt);
        }

        public async Task UpdateAsync(int id, UpdateDebtDto dto)
        {
            var debt = await _debtRepository.GetByIdAsync(id);

            if (debt == null)
                throw new Exception("Borç bulunamadı.");

            _mapper.Map(dto, debt);

            await _debtRepository.UpdateAsync(debt);
        }

        public async Task DeleteAsync(int id)
        {
            var debt = await _debtRepository.GetByIdAsync(id);

            if (debt == null)
                throw new Exception("Borç bulunamadı.");

            await _debtRepository.DeleteAsync(debt);
        }

        public async Task<List<DebtDto>> GetOverdueDebtsAsync()
        {
            var debts = await _debtRepository.GetOverdueDebtsAsync();

            return _mapper.Map<List<DebtDto>>(debts);
        }

        public async Task<List<DebtDto>> SearchByCustomerNameAsync(string customerName)
        {
            var debts = await _debtRepository.SearchByCustomerNameAsync(customerName);

            return _mapper.Map<List<DebtDto>>(debts);
        }

        public async Task<List<DebtDto>> GetPagedAsync(PaginationParams paginationParams)
        {
            var debts = await _debtRepository.GetPagedAsync(paginationParams);

            return _mapper.Map<List<DebtDto>>(debts);
        }

        public async Task<List<DebtDto>> GetSortedAsync(string sortBy, bool desc)
        {
            var debts = await _debtRepository.GetSortedAsync(sortBy, desc);

            return _mapper.Map<List<DebtDto>>(debts);
        }

        public async Task<List<DebtDto>> GetFilteredAsync(DebtFilterParams filterParams)
        {
            var debts = await _debtRepository.GetFilteredAsync(filterParams);

            return _mapper.Map<List<DebtDto>>(debts);
        }
    }
}