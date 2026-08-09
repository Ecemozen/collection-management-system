using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YigitTahsilat.API.Interfaces;

namespace YigitTahsilat.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]

    public class DashboardController : ControllerBase
    {
        private readonly IDashboardService _dashboardService;

        public DashboardController(IDashboardService dashboardService)
        {
            _dashboardService = dashboardService;
        }

        [HttpGet]
        public async Task<IActionResult> GetDashboard()
        {
            var result = await _dashboardService.GetDashboardAsync();
            return Ok(result);
        }
    }
}