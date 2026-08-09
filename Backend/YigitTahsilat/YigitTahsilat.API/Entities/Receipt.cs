namespace YigitTahsilat.API.Entities
{
    public class Receipt
    {
        public int Id { get; set; }

        public int PaymentId { get; set; }

        public Payment Payment { get; set; } = null!;

        public string ReceiptNumber { get; set; } = string.Empty;

        public DateTime CreatedDate { get; set; }

        public string? SignedFileName { get; set; }

        public string? SignedFilePath { get; set; }

        public DateTime? SignedUploadedDate { get; set; }
    }
}