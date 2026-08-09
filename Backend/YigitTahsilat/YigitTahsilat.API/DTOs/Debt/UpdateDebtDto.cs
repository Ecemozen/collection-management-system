namespace YigitTahsilat.API.DTOs.Debt
{
    public class UpdateDebtDto
    {
        public string InvoiceNumber { get; set; } = string.Empty;

        public decimal Amount { get; set; }

        public decimal RemainingAmount { get; set; }

        public DateTime DueDate { get; set; }

        public string Description { get; set; } = string.Empty;

        public string Status { get; set; } = string.Empty;
    }
}
