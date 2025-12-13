using BLL_.InterFace;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Model_;
using System.Net;

namespace APIUser.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TaiKhoanController : ControllerBase
    {
        private INguoiDung _iNguoiDung;
        public TaiKhoanController(INguoiDung dung) 
        {
            _iNguoiDung = dung;
        }
        [Route("getNguoiDungbyIDandMk")]
        [HttpGet]
        public IActionResult GetByTaiKhoan(string username, string password)
        {
            NguoiDung nd = new NguoiDung()
            {
                Id = Guid.Parse(username),
                MatKhau = password,
            };
            return Ok(_iNguoiDung.GetbyMkTKTaiKhoan(nd));
        }
    }
}
