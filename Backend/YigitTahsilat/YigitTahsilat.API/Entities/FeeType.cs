namespace YigitTahsilat.API.Entities
{
    public class FeeType
    {
        public int Id { get; set; }

        public string Name { get; set; } = string.Empty;

        public decimal Amount { get; set; }

        public ICollection<Payment> Payments { get; set; } = new List<Payment>();
    }
}