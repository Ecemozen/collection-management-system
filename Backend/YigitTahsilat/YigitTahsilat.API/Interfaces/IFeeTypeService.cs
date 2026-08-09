using YigitTahsilat.API.DTOs.FeeType;

namespace YigitTahsilat.API.Interfaces
{
    public interface IFeeTypeService
    {
        Task<List<FeeTypeDto>> GetAllAsync();

        Task<FeeTypeDto?> GetByIdAsync(int id);

        Task<FeeTypeDto> AddAsync(CreateFeeTypeDto dto);

        Task<bool> UpdateAsync(int id, UpdateFeeTypeDto dto);

        Task<bool> DeleteAsync(int id);
    }
}
