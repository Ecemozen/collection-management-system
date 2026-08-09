using AutoMapper;
using YigitTahsilat.API.DTOs.Payment;
using YigitTahsilat.API.Entities;
using YigitTahsilat.API.Interfaces;

namespace YigitTahsilat.API.Services
{
    public class PaymentService : IPaymentService
    {
        private readonly IPaymentRepository _paymentRepository;
        private readonly IDebtRepository _debtRepository;
        private readonly IMapper _mapper;

        public PaymentService(
            IPaymentRepository paymentRepository,
            IDebtRepository debtRepository,
            IMapper mapper)
        {
            _paymentRepository = paymentRepository;
            _debtRepository = debtRepository;
            _mapper = mapper;
        }

        public async Task<List<PaymentDto>> GetAllAsync()
        {
            var payments = await _paymentRepository.GetAllAsync();

            return payments.Select(payment => new PaymentDto
            {
                Id = payment.Id,
                DebtId = payment.DebtId,
                Amount = payment.Amount,
                PaymentDate = payment.PaymentDate,
                FeeTypeId = payment.FeeTypeId,
                Description = payment.Description,
                IsPaid = payment.IsPaid,
                CompanyName = payment.Debt?.Customer?.CompanyName ?? "",
                FeeTypeName = payment.FeeType?.Name ?? ""
            }).ToList();
        }

        public async Task<PaymentDto?> GetByIdAsync(int id)
        {
            var payment = await _paymentRepository.GetByIdAsync(id);

            if (payment == null)
                return null;

            return new PaymentDto
            {
                Id = payment.Id,
                DebtId = payment.DebtId,
                Amount = payment.Amount,
                PaymentDate = payment.PaymentDate,
                FeeTypeId = payment.FeeTypeId,
                Description = payment.Description,
                IsPaid = payment.IsPaid,

                CompanyName = payment.Debt?.Customer?.CompanyName ?? "",
                FeeTypeName = payment.FeeType?.Name ?? ""
            };
        }

        public async Task<PaymentDto> AddAsync(CreatePaymentDto dto)
        {
            var debt = await _debtRepository.GetByIdAsync(dto.DebtId);

            if (debt == null)
                throw new Exception("Borç bulunamadı.");

            if (dto.Amount <= 0)
                throw new Exception("Ödeme tutarı 0'dan büyük olmalıdır.");

            if (dto.Amount > debt.RemainingAmount)
                throw new Exception("Ödeme tutarı kalan borçtan büyük olamaz.");

            var payment = _mapper.Map<Payment>(dto);

            payment.IsPaid = true;

            await _paymentRepository.AddAsync(payment);

            debt.RemainingAmount -= dto.Amount;

            if (debt.RemainingAmount == 0)
                debt.Status = "Ödendi";
            else
                debt.Status = "Kısmi Ödendi";

            await _debtRepository.UpdateAsync(debt);

            return _mapper.Map<PaymentDto>(payment);
        }

        public async Task<bool> UpdateAsync(int id, UpdatePaymentDto dto)
        {
            var payment = await _paymentRepository.GetByIdAsync(id);

            if (payment == null)
                return false;

            _mapper.Map(dto, payment);

            await _paymentRepository.UpdateAsync(payment);

            return true;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var payment = await _paymentRepository.GetByIdAsync(id);

            if (payment == null)
                return false;

            await _paymentRepository.DeleteAsync(payment);

            return true;
        }
    }
}
