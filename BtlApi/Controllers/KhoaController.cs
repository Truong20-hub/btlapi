using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BLL_;
using BLL_.InterFace;
using Model_;



namespace btlapi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]

    public class KhoaController : ControllerBase
    {
        private IkhoaBLL _ikhoa;
        public KhoaController(IkhoaBLL ikhoa)
        {
            _ikhoa = ikhoa;
        }
        [Route("create-khoa")]
        
        [HttpPost]
        public IActionResult create([FromBody] Khoa khoa)
        {
            var result = _ikhoa.ThemKhoa(khoa);
            return Ok(new { j = result.i, i = result.k });
        }

    }
}
