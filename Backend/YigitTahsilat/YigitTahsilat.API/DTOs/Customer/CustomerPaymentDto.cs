namespace YigitTahsilat.API.DTOs.Customer
{
    public class CustomerPaymentDto
    {
        public DateTime PaymentDate { get; set; }

        public decimal Amount { get; set; }

        public bool IsPaid { get; set; }
    }
}