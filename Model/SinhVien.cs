using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model
{
    internal class SinhVien
    {
        public SinhVien(string iDSinhVien, string hoTen, string gioiTinh, DateTime ngaySinh, string nganhHoc, string khoaHoc, string maLopHC, int sDT, string email, string diaChi, string trangThai)
        {
            IDSinhVien = new Guid().ToString();
            HoTen = hoTen;
            GioiTinh = gioiTinh;
            NgaySinh = ngaySinh;
            NganhHoc = nganhHoc;
            KhoaHoc = khoaHoc;
            MaLopHC = maLopHC;
            SDT = sDT;
            Email = email;
            DiaChi = diaChi;
            TrangThai = trangThai;
        }

        public string IDSinhVien{ get; set; }
        public string HoTen { get; set; }
        public string GioiTinh { get; set; }
        public DateTime NgaySinh { get; set; }

        public string NganhHoc { get; set; }
        public string KhoaHoc { get; set; }
        public string MaLopHC { get; set; }
        public int SDT { get; set; }
        public string Email { get; set; }

        public string DiaChi { get; set; }
        public string TrangThai { get; set; }
    }
}
