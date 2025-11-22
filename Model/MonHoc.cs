using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model
{
    internal class MonHoc
    {
        public MonHoc(string iDMonHoc, int soTinChi, int soTiet, int thuTuUuTien, string tenMonHoc, string loaiMon, string iDNganh)
        {
            IDMonHoc = new Guid().ToString();
            SoTinChi = soTinChi;
            SoTiet = soTiet;
            ThuTuUuTien = thuTuUuTien;
            TenMonHoc = tenMonHoc;
            LoaiMon = loaiMon;
            IDNganh = iDNganh;
        }

        public string IDMonHoc { get; set; }
        public int SoTinChi { get; set; }
        public int SoTiet { get; set; }
        public int ThuTuUuTien { get; set; }
        public string TenMonHoc { get; set; }
        public string LoaiMon { get; set; }
        public string IDNganh { get; set; }
    }
}
