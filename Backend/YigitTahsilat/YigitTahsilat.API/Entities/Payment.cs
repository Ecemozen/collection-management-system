using System;

namespace YigitTahsilat.API.Entities
{
    public class Payment
    {
        public int Id { get; set; }

        public int DebtId { get; set; }
        public Debt? Debt { get; set; }

      

        public int FeeTypeId { get; set; }
        public FeeType? FeeType { get; set; }

        public decimal Amount { get; set; }

        public DateTime PaymentDate { get; set; }

        public string Description { get; set; } = string.Empty;

        public bool IsPaid { get; set; }

        public Receipt? Receipt { get; set; }
    }
}