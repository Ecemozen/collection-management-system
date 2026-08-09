using FluentValidation;
using YigitTahsilat.API.DTOs.Receipt;

namespace YigitTahsilat.API.Validators
{
    public class ReceiptValidator : AbstractValidator<CreateReceiptDto>
    {
        public ReceiptValidator()
        {
            RuleFor(x => x.PaymentId)
                .GreaterThan(0)
                .WithMessage("Geçerli bir ödeme seçiniz.");
        }
    }
}