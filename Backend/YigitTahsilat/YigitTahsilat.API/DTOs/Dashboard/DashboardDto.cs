namespace YigitTahsilat.API.DTOs.Dashboard
{
    public class DashboardDto
    {
        public int TotalCustomers { get; set; }

        public decimal TotalDebtAmount { get; set; }

        public decimal TotalCollectedAmount { get; set; }

        public decimal RemainingAmount { get; set; }

        public int OverdueDebtCount { get; set; }

        public int PendingDebtCount { get; set; }

        public int PaidDebtCount { get; set; }
    }
}