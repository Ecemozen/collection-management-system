namespace YigitTahsilat.API.DTOs.Customer
{
    public class CustomerDto
    {
        public int Id { get; set; }

        public string CustomerCode { get; set; } = string.Empty;

        public string CompanyName { get; set; } = string.Empty;

        public string AuthorizedPerson { get; set; } = string.Empty;

        public string Phone { get; set; } = string.Empty;

        public string Email { get; set; } = string.Empty;

        public string Address { get; set; } = string.Empty;

        public string TaxOffice { get; set; } = string.Empty;

        public string TaxNumber { get; set; } = string.Empty;

        public bool IsActive { get; set; }

        public decimal Balance { get; set; }

        public decimal TotalCollected { get; set; }

        public decimal PendingCollection { get; set; }

        public List<CustomerPaymentDto> Payments { get; set; } = new();
    }
}