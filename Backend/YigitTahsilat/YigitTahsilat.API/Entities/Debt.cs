using System.Collections.Generic;

namespace YigitTahsilat.API.Entities

{
    public class Debt
    {
        public int Id { get; set; }

        public int CustomerId { get; set; }

        public Customer Customer { get; set; } = null!;

        public string InvoiceNumber { get; set; } = string.Empty;

        public decimal Amount { get; set; }

        public decimal RemainingAmount { get; set; }

        public DateTime DueDate { get; set; }

        public string Description { get; set; } = string.Empty;

        public string Status { get; set; } = "Bekliyor";

        public ICollection<Payment> Payments { get; set; } = new List<Payment>();
    }
}