using YigitTahsilat.API.DTOs.Dashboard;

namespace YigitTahsilat.API.Interfaces
{
    public interface IDashboardService
    {
        Task<DashboardDto> GetDashboardAsync();
    }
}