namespace YigitTahsilat.API.DTOs.FeeType
{
    public class FeeTypeDto
    {
        public int Id { get; set; }

        public string Name { get; set; } = string.Empty;

        public decimal Amount { get; set; }
    }
}
