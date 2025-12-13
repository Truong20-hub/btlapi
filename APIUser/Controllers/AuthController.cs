using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace APIUser.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        [HttpPost("login")]
        public IActionResult login(string useName,string passWork)
        {
            if (useName != "admin" || passWork != "123")
                return Unauthorized();

            var claims = new[]
            {
                new Claim(ClaimTypes.Name, useName),
                new Claim("Role", "Admin")
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes("supersecretkey123456789"));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: "https://localhost:7062",
                audience: "https://localhost:7000",
                claims: claims,
                expires: DateTime.Now.AddHours(3),
                signingCredentials: creds
            );

            return Ok(new
            {
                token = new JwtSecurityTokenHandler().WriteToken(token)
            });
        }
    }
}
