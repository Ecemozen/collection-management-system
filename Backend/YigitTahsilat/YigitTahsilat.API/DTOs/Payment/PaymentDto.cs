namespace YigitTahsilat.API.DTOs.Payment
{
    public class PaymentDto
    {
        public int Id { get; set; }

        public int DebtId { get; set; }

        public decimal Amount { get; set; }

        public DateTime PaymentDate { get; set; }

        public int FeeTypeId { get; set; }

        public string Description { get; set; } = string.Empty;

        public bool IsPaid { get; set; }

        public string CompanyName { get; set; } = string.Empty;

        public string FeeTypeName { get; set; } = string.Empty;
    }
}