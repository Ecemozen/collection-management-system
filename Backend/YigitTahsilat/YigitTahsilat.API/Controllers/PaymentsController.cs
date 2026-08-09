using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YigitTahsilat.API.DTOs.Payment;
using YigitTahsilat.API.Interfaces;

namespace YigitTahsilat.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]

    public class PaymentsController : ControllerBase
    {
        private readonly IPaymentService _paymentService;

        public PaymentsController(IPaymentService paymentService)
        {
            _paymentService = paymentService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var payments = await _paymentService.GetAllAsync();
            return Ok(payments);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var payment = await _paymentService.GetByIdAsync(id);

            if (payment == null)
                return NotFound();

            return Ok(payment);
        }

        [HttpPost]
        public async Task<IActionResult> Create(CreatePaymentDto dto)
        {
            var payment = await _paymentService.AddAsync(dto);

            return CreatedAtAction(
                nameof(GetById),
                new { id = payment.Id },
                payment);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, UpdatePaymentDto dto)
        {
            var result = await _paymentService.UpdateAsync(id, dto);

            if (!result)
                return NotFound();

            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var result = await _paymentService.DeleteAsync(id);

            if (!result)
                return NotFound();

            return NoContent();
        }
    }
}
