namespace YigitTahsilat.API.DTOs.Common
{
    public class DebtFilterParams
    {
        public string? Status { get; set; }

        public decimal? MinAmount { get; set; }

        public decimal? MaxAmount { get; set; }

        public DateTime? StartDate { get; set; }

        public DateTime? EndDate { get; set; }
    }
}