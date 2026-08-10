using Microsoft.AspNetCore.Mvc;
using YigitTahsilat.API.DTOs.Receipt;
using YigitTahsilat.API.Interfaces;

namespace YigitTahsilat.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ReceiptsController : ControllerBase
    {
        private readonly IReceiptService _receiptService;

        public ReceiptsController(IReceiptService receiptService)
        {
            _receiptService = receiptService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            return Ok(await _receiptService.GetAllAsync());
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var receipt = await _receiptService.GetByIdAsync(id);

            if (receipt == null)
                return NotFound();

            return Ok(receipt);
        }

        [HttpPost]
        public async Task<IActionResult> Create(CreateReceiptDto dto)
        {
            var receipt = await _receiptService.AddAsync(dto);

            return CreatedAtAction(
                nameof(GetById),
                new { id = receipt.Id },
                receipt);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(
            int id,
            UpdateReceiptDto dto)
        {
            var result = await _receiptService.UpdateAsync(id, dto);

            if (!result)
                return NotFound();

            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var result = await _receiptService.DeleteAsync(id);

            if (!result)
                return NotFound();

            return NoContent();
        }

        // İmzalı makbuz yükleme
        [HttpPost("{id}/signed")]
        [RequestSizeLimit(50 * 1024 * 1024)]
        public async Task<IActionResult> UploadSignedReceipt(
            int id,
            IFormFile file)
        {
            try
            {
                var result =
                    await _receiptService.UploadSignedReceiptAsync(id, file);

                if (!result)
                    return NotFound("Makbuz bulunamadı.");

                return Ok(new
                {
                    message = "İmzalı makbuz başarıyla yüklendi."
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new
                {
                    message = ex.Message
                });
            }
        }

        // İmzalı makbuzu görüntüleme/indirme
        [HttpGet("{id}/signed")]
        public async Task<IActionResult> GetSignedReceipt(int id)
        {
            var result =
                await _receiptService.GetSignedReceiptAsync(id);

            if (result == null)
                return NotFound("İmzalı makbuz bulunamadı.");

            return File(
                result.Value.FileBytes,
                result.Value.ContentType,
                result.Value.FileName);
        }
    }
}