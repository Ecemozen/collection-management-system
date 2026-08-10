using AutoMapper;
using Microsoft.AspNetCore.Http;
using YigitTahsilat.API.DTOs.Receipt;
using YigitTahsilat.API.Entities;
using YigitTahsilat.API.Interfaces;

namespace YigitTahsilat.API.Services
{
    public class ReceiptService : IReceiptService
    {
        private readonly IReceiptRepository _receiptRepository;
        private readonly IPaymentRepository _paymentRepository;
        private readonly IMapper _mapper;

        public ReceiptService(
            IReceiptRepository receiptRepository,
            IPaymentRepository paymentRepository,
            IMapper mapper)
        {
            _receiptRepository = receiptRepository;
            _paymentRepository = paymentRepository;
            _mapper = mapper;
        }

        public async Task<List<ReceiptDto>> GetAllAsync()
        {
            var receipts = await _receiptRepository.GetAllAsync();

            return receipts.Select(receipt => new ReceiptDto
            {
                Id = receipt.Id,
                PaymentId = receipt.PaymentId,
                ReceiptNumber = receipt.ReceiptNumber,
                CreatedDate = receipt.CreatedDate,

                CompanyName =
                    receipt.Payment?.Debt?.Customer?.CompanyName ?? "",

                Amount =
                    receipt.Payment?.Amount ?? 0,

                PaymentDate =
                    receipt.Payment?.PaymentDate ?? DateTime.MinValue,

                FeeTypeName =
                    receipt.Payment?.FeeType?.Name ?? "",

                Description =
                    receipt.Payment?.Description ?? "",

                SignedFileName =
                    receipt.SignedFileName,

                SignedFilePath =
                    receipt.SignedFilePath,

                SignedUploadedDate =
                    receipt.SignedUploadedDate

            }).ToList();
        }

        public async Task<ReceiptDto?> GetByIdAsync(int id)
        {
            var receipt = await _receiptRepository.GetByIdAsync(id);

            if (receipt == null)
                return null;

            return new ReceiptDto
            {
                Id = receipt.Id,
                PaymentId = receipt.PaymentId,
                ReceiptNumber = receipt.ReceiptNumber,
                CreatedDate = receipt.CreatedDate,

                CompanyName =
                    receipt.Payment?.Debt?.Customer?.CompanyName ?? "",

                Amount =
                    receipt.Payment?.Amount ?? 0,

                PaymentDate =
                    receipt.Payment?.PaymentDate ?? DateTime.MinValue,

                FeeTypeName =
                    receipt.Payment?.FeeType?.Name ?? "",

                Description =
                    receipt.Payment?.Description ?? "",

                SignedFileName =
                    receipt.SignedFileName,

                SignedFilePath =
                    receipt.SignedFilePath,

                SignedUploadedDate =
                    receipt.SignedUploadedDate
            };
        }

        public async Task<ReceiptDto> AddAsync(CreateReceiptDto dto)
        {
            var payment =
                await _paymentRepository.GetByIdAsync(dto.PaymentId);

            if (payment == null)
                throw new Exception("Tahsilat bulunamadı.");

            var existingReceipt =
                await _receiptRepository.GetByPaymentIdAsync(dto.PaymentId);

            if (existingReceipt != null)
            {
                return new ReceiptDto
                {
                    Id = existingReceipt.Id,
                    PaymentId = existingReceipt.PaymentId,
                    ReceiptNumber = existingReceipt.ReceiptNumber,
                    CreatedDate = existingReceipt.CreatedDate,

                    CompanyName =
                        payment.Debt?.Customer?.CompanyName ?? "",

                    Amount =
                        payment.Amount,

                    PaymentDate =
                        payment.PaymentDate,

                    FeeTypeName =
                        payment.FeeType?.Name ?? "",

                    Description =
                        payment.Description,

                    SignedFileName =
                        existingReceipt.SignedFileName,

                    SignedFilePath =
                        existingReceipt.SignedFilePath,

                    SignedUploadedDate =
                        existingReceipt.SignedUploadedDate
                };
            }

            var receipt = new Receipt
            {
                PaymentId = dto.PaymentId,

                ReceiptNumber =
                    $"MKB-{DateTime.Now:yyyyMMddHHmmssfff}",

                CreatedDate = DateTime.Now
            };

            await _receiptRepository.AddAsync(receipt);

            return new ReceiptDto
            {
                Id = receipt.Id,
                PaymentId = receipt.PaymentId,
                ReceiptNumber = receipt.ReceiptNumber,
                CreatedDate = receipt.CreatedDate,

                CompanyName =
                    payment.Debt?.Customer?.CompanyName ?? "",

                Amount =
                    payment.Amount,

                PaymentDate =
                    payment.PaymentDate,

                FeeTypeName =
                    payment.FeeType?.Name ?? "",

                Description =
                    payment.Description,

                SignedFileName =
                    receipt.SignedFileName,

                SignedFilePath =
                    receipt.SignedFilePath,

                SignedUploadedDate =
                    receipt.SignedUploadedDate
            };
        }

        public async Task<bool> UpdateAsync(
            int id,
            UpdateReceiptDto dto)
        {
            var receipt =
                await _receiptRepository.GetByIdAsync(id);

            if (receipt == null)
                return false;

            receipt.ReceiptNumber =
                dto.ReceiptNumber;

            await _receiptRepository.UpdateAsync(receipt);

            return true;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var receipt =
                await _receiptRepository.GetByIdAsync(id);

            if (receipt == null)
                return false;

            await _receiptRepository.DeleteAsync(receipt);

            return true;
        }

        // ============================================================
        // İMZALI MAKBUZ YÜKLEME
        // ============================================================

        public async Task<bool> UploadSignedReceiptAsync(
            int id,
            IFormFile file)
        {
            var receipt =
                await _receiptRepository.GetByIdAsync(id);

            if (receipt == null)
                return false;

            if (file == null || file.Length == 0)
                throw new Exception("Dosya seçilmedi.");

            var extension =
                Path.GetExtension(file.FileName)
                    .ToLowerInvariant();

            var allowedExtensions = new[]
            {
                ".pdf",
                ".jpg",
                ".jpeg",
                ".png"
            };

            if (!allowedExtensions.Contains(extension))
            {
                throw new Exception(
                    "Sadece PDF, JPG, JPEG ve PNG dosyaları yüklenebilir.");
            }

            const long maxFileSize = 50 * 1024 * 1024;

            if (file.Length > maxFileSize)
            {
                throw new Exception(
                    "Dosya boyutu 10 MB'dan büyük olamaz.");
            }

            var uploadFolder =
                Path.Combine(
                    Directory.GetCurrentDirectory(),
                    "wwwroot",
                    "uploads",
                    "signed-receipts");

            Directory.CreateDirectory(uploadFolder);

            var uniqueFileName =
                $"{Guid.NewGuid()}{extension}";

            var filePath =
                Path.Combine(
                    uploadFolder,
                    uniqueFileName);

            await using (var stream =
                new FileStream(
                    filePath,
                    FileMode.Create,
                    FileAccess.Write,
                    FileShare.None))
            {
                await file.CopyToAsync(stream);
            }

            // Veritabanına dosya bilgilerini kaydet
            receipt.SignedFileName =
                file.FileName;

            receipt.SignedFilePath =
                $"/uploads/signed-receipts/{uniqueFileName}";

            receipt.SignedUploadedDate =
                DateTime.Now;

            await _receiptRepository.UpdateAsync(receipt);

            return true;
        }

        // ============================================================
        // İMZALI MAKBUZU GÖRÜNTÜLEME / İNDİRME
        // ============================================================

        public async Task<(
            byte[] FileBytes,
            string ContentType,
            string FileName
        )?> GetSignedReceiptAsync(int id)
        {
            var receipt =
                await _receiptRepository.GetByIdAsync(id);

            if (receipt == null)
                return null;

            if (string.IsNullOrWhiteSpace(
                receipt.SignedFilePath))
            {
                return null;
            }

            var relativePath =
                receipt.SignedFilePath
                    .TrimStart('/')
                    .Replace(
                        '/',
                        Path.DirectorySeparatorChar);

            var filePath =
                Path.Combine(
                    Directory.GetCurrentDirectory(),
                    "wwwroot",
                    relativePath);

            if (!System.IO.File.Exists(filePath))
                return null;

            var fileBytes =
                await System.IO.File.ReadAllBytesAsync(
                    filePath);

            var extension =
                Path.GetExtension(filePath)
                    .ToLowerInvariant();

            var contentType =
                extension switch
                {
                    ".pdf" => "application/pdf",
                    ".jpg" => "image/jpeg",
                    ".jpeg" => "image/jpeg",
                    ".png" => "image/png",
                    _ => "application/octet-stream"
                };

            var fileName =
                string.IsNullOrWhiteSpace(
                    receipt.SignedFileName)
                    ? Path.GetFileName(filePath)
                    : receipt.SignedFileName;

            return (
                fileBytes,
                contentType,
                fileName
            );
        }
    }
}