using FluentValidation;
using YigitTahsilat.API.DTOs.Debt;

namespace YigitTahsilat.API.Validators
{
    public class DebtValidator : AbstractValidator<CreateDebtDto>
    {
        public DebtValidator()
        {
            RuleFor(x => x.CustomerId)
                .GreaterThan(0)
                .WithMessage("Geçerli bir müşteri seçiniz.");

            RuleFor(x => x.InvoiceNumber)
                .NotEmpty()
                .MaximumLength(50);

            RuleFor(x => x.Amount)
                .GreaterThan(0)
                .WithMessage("Borç tutarı 0'dan büyük olmalıdır.");

            RuleFor(x => x.DueDate)
                .NotEmpty()
                .WithMessage("Vade tarihi zorunludur.");

            RuleFor(x => x.Description)
                .MaximumLength(250);
        }
    }
}