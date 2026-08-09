using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using YigitTahsilat.API.Data;
using YigitTahsilat.API.DTOs;
using YigitTahsilat.API.DTOs.Auth;

namespace YigitTahsilat.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AuthController(AppDbContext context)
        {
            _context = context;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto model)
        {
            if (model == null || string.IsNullOrEmpty(model.Email) || string.IsNullOrEmpty(model.Password))
            {
                return BadRequest(new { success = false, message = "E-posta ve şifre alanları boş olamaz." });
            }

            // Veritabanındaki şifre kolonunun adına göre burayı ayarlıyoruz. 
            // Eğer kolonun adı PasswordHash ise u.PasswordHash == model.Password yapmalısın.
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == model.Email && u.PasswordHash == model.Password);

            if (user == null)
            {
                return Unauthorized(new { success = false, message = "Geçersiz e-posta veya şifre." });
            }

            return Ok(new
            {
                success = true,
                message = "Giriş başarılı.",
                data = new
                {
                    userId = user.Id,
                    email = user.Email,
                    fullName = user.FullName
                }
            });
        }
    }
}