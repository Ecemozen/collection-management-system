namespace YigitTahsilat.API.DTOs.Receipt
{
    public class ReceiptListDto
    {
        public int Id { get; set; }

        public string ReceiptNumber { get; set; } = string.Empty;

        public DateTime CreatedDate { get; set; }
    }
}
