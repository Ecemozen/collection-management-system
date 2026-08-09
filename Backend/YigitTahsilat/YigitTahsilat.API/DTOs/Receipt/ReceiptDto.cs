namespace YigitTahsilat.API.DTOs.Receipt
{
    public class ReceiptDto
    {
        public int Id { get; set; }

        public int PaymentId { get; set; }

        public string ReceiptNumber { get; set; } = string.Empty;

        public DateTime CreatedDate { get; set; }

        public string CompanyName { get; set; } = string.Empty;

        public decimal Amount { get; set; }

        public DateTime PaymentDate { get; set; }

        public string FeeTypeName { get; set; } = string.Empty;

        public string Description { get; set; } = string.Empty;

        public string? SignedFileName { get; set; }

        public string? SignedFilePath { get; set; }

        public DateTime? SignedUploadedDate { get; set; }
    }
}