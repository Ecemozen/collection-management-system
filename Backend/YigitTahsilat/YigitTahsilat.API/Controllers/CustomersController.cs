using Microsoft.AspNetCore.Mvc;
using YigitTahsilat.API.DTOs.Customer;
using YigitTahsilat.API.Interfaces;
using Microsoft.AspNetCore.Authorization;

namespace YigitTahsilat.API.Controllers
{
    
    [ApiController]
    [Route("api/[controller]")]
    public class CustomersController : ControllerBase
    {
        private readonly ICustomerService _customerService;

        public CustomersController(ICustomerService customerService)
        {
            _customerService = customerService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var customers = await _customerService.GetAllAsync();
            return Ok(customers);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var customer = await _customerService.GetByIdAsync(id);

            if (customer == null)
                return NotFound();

            return Ok(customer);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateCustomerDto dto)
        {
            var customer = await _customerService.AddAsync(dto);

            return CreatedAtAction(
                nameof(GetById),
                new { id = customer.Id },
                customer);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateCustomerDto dto)
        {
            await _customerService.UpdateAsync(id, dto);

            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            await _customerService.DeleteAsync(id);

            return NoContent();
        }
    }
}