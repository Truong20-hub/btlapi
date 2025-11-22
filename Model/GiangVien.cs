using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model
{
    internal class GiangVien
    {
        public GiangVien(string iDGV, string tenGiangVien, string gioiTinh, DateTime ngaySinh, string trinhDo, string khoa, string mon, int sDT, string email, string diaChi, List<LopHoc> danhSachLH)
        {
            IDGV = new Guid().ToString();
            TenGiangVien = tenGiangVien;
            GioiTinh = gioiTinh;
            NgaySinh = ngaySinh;
            TrinhDo = trinhDo;
            Khoa = khoa;
            Mon = mon;
            SDT = sDT;
            Email = email;
            DiaChi = diaChi;
            DanhSachLH = danhSachLH;
        }

        public string IDGV { get; set; }
        public string TenGiangVien { get; set; }
        public string GioiTinh { get; set; }
        public DateTime NgaySinh { get; set; }

        public string TrinhDo { get; set; }
        public string Khoa { get; set; }
        public string Mon { get; set; }
        public int SDT { get; set; }
        public string Email { get; set; }
        public string DiaChi { get; set; }
        public List<LopHoc> DanhSachLH { get; set; }
    }
}
