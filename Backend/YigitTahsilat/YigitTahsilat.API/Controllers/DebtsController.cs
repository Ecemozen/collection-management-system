using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using YigitTahsilat.API.DTOs.Common;
using YigitTahsilat.API.DTOs.Debt;
using YigitTahsilat.API.Entities;
using YigitTahsilat.API.Interfaces;
using YigitTahsilat.API.Services;

namespace YigitTahsilat.API.Controllers
{
    
    [Route("api/[controller]")]
    [ApiController]
    public class DebtsController : ControllerBase
    {
        private readonly IDebtService _debtService;
        private readonly PdfService _pdfService;
        private readonly ExcelService _excelService;
        private readonly ILogger<DebtsController> _logger;

        public DebtsController(
            IDebtService debtService,
            PdfService pdfService,
            ExcelService excelService,
            ILogger<DebtsController> logger)
        {
            _debtService = debtService;
            _pdfService = pdfService;
            _excelService = excelService;
            _logger = logger;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            _logger.LogInformation("Tüm borçlar listelendi.");

            var debts = await _debtService.GetAllAsync();

            return Ok(debts);
        }

        [HttpGet("paged")]
        public async Task<IActionResult> GetPaged([FromQuery] PaginationParams paginationParams)
        {
            var debts = await _debtService.GetPagedAsync(paginationParams);

            return Ok(debts);
        }

        [HttpGet("sort")]
        public async Task<IActionResult> GetSorted(
            [FromQuery] string sortBy,
            [FromQuery] bool desc = false)
        {
            var debts = await _debtService.GetSortedAsync(sortBy, desc);

            return Ok(debts);
        }
        [HttpGet("filter")]
        public async Task<IActionResult> GetFiltered([FromQuery] DebtFilterParams filterParams)
        {
            var debts = await _debtService.GetFilteredAsync(filterParams);

            return Ok(debts);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var debt = await _debtService.GetByIdAsync(id);

            if (debt == null)
                return NotFound();

            return Ok(debt);
        }

        [HttpGet("overdue")]
        public async Task<IActionResult> GetOverdueDebts()
        {
            var debts = await _debtService.GetOverdueDebtsAsync();

            return Ok(debts);
        }

        [HttpGet("search")]
        public async Task<IActionResult> SearchByCustomerName([FromQuery] string customerName)
        {
            var debts = await _debtService.SearchByCustomerNameAsync(customerName);

            return Ok(debts);
        }

        [HttpPost]
        public async Task<IActionResult> Create(CreateDebtDto dto)
        {
            _logger.LogInformation("Yeni borç oluşturuluyor.");

            var debt = await _debtService.AddAsync(dto);

            return CreatedAtAction(
                nameof(GetById),
                new { id = debt.Id },
                debt);
        }
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, UpdateDebtDto dto)
        {
            _logger.LogInformation("Borç güncelleniyor. Id: {Id}", id);

            await _debtService.UpdateAsync(id, dto);

            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            _logger.LogInformation("Borç siliniyor. Id: {Id}", id);

            await _debtService.DeleteAsync(id);

            return NoContent();
        }

        [HttpGet("report")]
        public async Task<IActionResult> GenerateReport()
        {
            _logger.LogInformation("PDF raporu oluşturuldu.");

            var debtDtos = await _debtService.GetAllAsync();

            var debts = debtDtos.Select(x => new Debt
            {
                InvoiceNumber = x.InvoiceNumber,
                Amount = x.Amount,
                RemainingAmount = x.RemainingAmount,
                Status = x.Status
            }).ToList();

            var pdf = _pdfService.GenerateDebtReport(debts);

            return File(
                pdf,
                "application/pdf",
                "DebtReport.pdf");
        }
        [HttpGet("excel")]
        public async Task<IActionResult> GenerateExcel()
        {
            _logger.LogInformation("Excel raporu oluşturuldu.");

            var debtDtos = await _debtService.GetAllAsync();

            var debts = debtDtos.Select(x => new Debt
            {
                InvoiceNumber = x.InvoiceNumber,
                Amount = x.Amount,
                RemainingAmount = x.RemainingAmount,
                Status = x.Status
            }).ToList();

            var excel = _excelService.GenerateDebtReport(debts);

            return File(
                excel,
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                "DebtReport.xlsx");
        }
    }
}