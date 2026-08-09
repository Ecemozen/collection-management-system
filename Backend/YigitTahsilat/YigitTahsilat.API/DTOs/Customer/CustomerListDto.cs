namespace YigitTahsilat.API.DTOs.Customer
{
    public class CustomerListDto
    {
        public int Id { get; set; }

        public string CustomerCode { get; set; } = string.Empty;

        public string CompanyName { get; set; } = string.Empty;

        public string AuthorizedPerson { get; set; } = string.Empty;

        public string Phone { get; set; } = string.Empty;

        public decimal Balance { get; set; }

        public bool IsActive { get; set; }
    }
}