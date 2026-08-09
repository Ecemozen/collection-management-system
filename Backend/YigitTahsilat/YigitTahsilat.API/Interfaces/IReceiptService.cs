using YigitTahsilat.API.DTOs.Receipt;
using Microsoft.AspNetCore.Http;

namespace YigitTahsilat.API.Interfaces
{
    public interface IReceiptService
    {
        Task<bool> UploadSignedReceiptAsync(int id, IFormFile file);

        Task<List<ReceiptDto>> GetAllAsync();

        Task<ReceiptDto?> GetByIdAsync(int id);

        Task<ReceiptDto> AddAsync(CreateReceiptDto dto);

        Task<bool> UpdateAsync(int id, UpdateReceiptDto dto);

        Task<bool> DeleteAsync(int id);
    }
}