using AutoMapper;
using YigitTahsilat.API.DTOs.FeeType;
using YigitTahsilat.API.Entities;
using YigitTahsilat.API.Interfaces;

namespace YigitTahsilat.API.Services
{
    public class FeeTypeService : IFeeTypeService
    {
        private readonly IFeeTypeRepository _feeTypeRepository;
        private readonly IMapper _mapper;

        public FeeTypeService(
            IFeeTypeRepository feeTypeRepository,
            IMapper mapper)
        {
            _feeTypeRepository = feeTypeRepository;
            _mapper = mapper;
        }

        public async Task<List<FeeTypeDto>> GetAllAsync()
        {
            var feeTypes = await _feeTypeRepository.GetAllAsync();
            return _mapper.Map<List<FeeTypeDto>>(feeTypes);
        }

        public async Task<FeeTypeDto?> GetByIdAsync(int id)
        {
            var feeType = await _feeTypeRepository.GetByIdAsync(id);

            if (feeType == null)
                return null;

            return _mapper.Map<FeeTypeDto>(feeType);
        }

        public async Task<FeeTypeDto> AddAsync(CreateFeeTypeDto dto)
        {
            var feeType = _mapper.Map<FeeType>(dto);

            await _feeTypeRepository.AddAsync(feeType);

            return _mapper.Map<FeeTypeDto>(feeType);
        }

        public async Task<bool> UpdateAsync(int id, UpdateFeeTypeDto dto)
        {
            var feeType = await _feeTypeRepository.GetByIdAsync(id);

            if (feeType == null)
                return false;

            _mapper.Map(dto, feeType);

            await _feeTypeRepository.UpdateAsync(feeType);

            return true;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var feeType = await _feeTypeRepository.GetByIdAsync(id);

            if (feeType == null)
                return false;

            await _feeTypeRepository.DeleteAsync(feeType);

            return true;
        }
    }
}