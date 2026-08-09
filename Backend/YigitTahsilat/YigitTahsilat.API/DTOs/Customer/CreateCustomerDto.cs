namespace YigitTahsilat.API.DTOs.Customer
{
    public class CreateCustomerDto
    {
        public string CustomerCode { get; set; } = string.Empty;

        public string CompanyName { get; set; } = string.Empty;

        public string AuthorizedPerson { get; set; } = string.Empty;

        public string Phone { get; set; } = string.Empty;

        public string Email { get; set; } = string.Empty;

        public string Address { get; set; } = string.Empty;

        public string TaxOffice { get; set; } = string.Empty;

        public string TaxNumber { get; set; } = string.Empty;
    }
}