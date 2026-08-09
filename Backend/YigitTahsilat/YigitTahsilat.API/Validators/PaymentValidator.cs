using FluentValidation;
using YigitTahsilat.API.DTOs.Payment;

namespace YigitTahsilat.API.Validators
{
    public class PaymentValidator : AbstractValidator<CreatePaymentDto>
    {
        public PaymentValidator()
        {
            RuleFor(x => x.DebtId)
                .GreaterThan(0)
                .WithMessage("Geçerli bir borç seçiniz.");

            RuleFor(x => x.Amount)
                .GreaterThan(0)
                .WithMessage("Ödeme tutarı 0'dan büyük olmalıdır.");

            RuleFor(x => x.PaymentDate)
                .NotEmpty()
                .WithMessage("Ödeme tarihi zorunludur.");

            RuleFor(x => x.FeeTypeId)
                .GreaterThan(0)
                .WithMessage("Geçerli bir ödeme tipi seçiniz.");

            RuleFor(x => x.Description)
                .MaximumLength(250)
                .WithMessage("Açıklama en fazla 250 karakter olabilir.");
        }
    }
}