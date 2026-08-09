namespace YigitTahsilat.API.DTOs.Payment
{
    public class UpdatePaymentDto
    {
        public decimal Amount { get; set; }

        public DateTime PaymentDate { get; set; }

        public int FeeTypeId { get; set; }

        public string Description { get; set; } = string.Empty;
    }
}