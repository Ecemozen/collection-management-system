using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YigitTahsilat.API.DTOs.FeeType;
using YigitTahsilat.API.Interfaces;

namespace YigitTahsilat.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
  
    public class FeeTypesController : ControllerBase
    {
        private readonly IFeeTypeService _feeTypeService;

        public FeeTypesController(IFeeTypeService feeTypeService)
        {
            _feeTypeService = feeTypeService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            return Ok(await _feeTypeService.GetAllAsync());
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var feeType = await _feeTypeService.GetByIdAsync(id);

            if (feeType == null)
                return NotFound();

            return Ok(feeType);
        }

        [HttpPost]
        public async Task<IActionResult> Create(CreateFeeTypeDto dto)
        {
            var feeType = await _feeTypeService.AddAsync(dto);

            return Ok(feeType);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, UpdateFeeTypeDto dto)
        {
            var result = await _feeTypeService.UpdateAsync(id, dto);

            if (!result)
                return NotFound();

            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var result = await _feeTypeService.DeleteAsync(id);

            if (!result)
                return NotFound();

            return NoContent();
        }
    }
}