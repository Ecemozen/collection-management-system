namespace YigitTahsilat.API.DTOs.Debt
{
    public class CreateDebtDto
    {
        public int CustomerId { get; set; }

        public string InvoiceNumber { get; set; } = string.Empty;

        public decimal Amount { get; set; }

        public DateTime DueDate { get; set; }

        public string Description { get; set; } = string.Empty;
    }
}