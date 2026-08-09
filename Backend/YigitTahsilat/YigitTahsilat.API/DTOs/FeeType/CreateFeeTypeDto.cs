namespace YigitTahsilat.API.DTOs.FeeType
{
    public class CreateFeeTypeDto
    {
        public string Name { get; set; } = string.Empty;

        public decimal Amount { get; set; }
    }
}