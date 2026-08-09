using FluentValidation;
using YigitTahsilat.API.DTOs.FeeType;

namespace YigitTahsilat.API.Validators
{
    public class FeeTypeValidator : AbstractValidator<CreateFeeTypeDto>
    {
        public FeeTypeValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty()
                .MaximumLength(100)
                .WithMessage("Ücret tipi adı zorunludur.");

            RuleFor(x => x.Amount)
                .GreaterThanOrEqualTo(0)
                .WithMessage("Tutar negatif olamaz.");
        }
    }
}