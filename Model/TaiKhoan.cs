using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model
{
    internal class TaiKhoan
    {
        public TaiKhoan(string tenDangNhap, string matKhau, string quyenHan, string nguoiDung)
        {
            TenDangNhap = tenDangNhap;
            MatKhau = matKhau;
            QuyenHan = quyenHan;
            NguoiDung = nguoiDung;
        }

        public string TenDangNhap { get; set; }
        public string MatKhau { get; set; }
        public string QuyenHan { get; set; }
        public string NguoiDung { get; set; }
    }
}
