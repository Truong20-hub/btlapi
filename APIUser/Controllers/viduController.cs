using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace APIUser.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class viduController : ControllerBase
    {
        [HttpGet]
        public IActionResult action()
        {
            return Ok( new { id = 0 });
        } 
    }
}
