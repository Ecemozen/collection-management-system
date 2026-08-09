using FluentValidation;
using YigitTahsilat.API.DTOs.Customer;

namespace YigitTahsilat.API.Validators
{
    public class CustomerValidator : AbstractValidator<CreateCustomerDto>
    {
        public CustomerValidator()
        {
            RuleFor(x => x.CompanyName)
                .NotEmpty()
                .WithMessage("Firma adı zorunludur.")
                .MaximumLength(100);

            RuleFor(x => x.AuthorizedPerson)
                .NotEmpty()
                .WithMessage("Yetkili kişi zorunludur.");

            RuleFor(x => x.Phone)
                .NotEmpty()
                .Length(11);

            RuleFor(x => x.Email)
                .EmailAddress()
                .When(x => !string.IsNullOrEmpty(x.Email));

            RuleFor(x => x.TaxNumber)
                .NotEmpty();

            RuleFor(x => x.TaxOffice)
                .NotEmpty();
        }
    }
}