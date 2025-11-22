using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model
{
    internal class LichHoc
    {
        public LichHoc(string iDLopPhan, DateTime ngayHoc, int soTiet, string phongHoc, string ghiChu, string iDLichHoc)
        {
            IDLopPhan = new Guid().ToString();
            NgayHoc = ngayHoc;
            SoTiet = soTiet;
            PhongHoc = phongHoc;
            GhiChu = ghiChu;
            IDLichHoc = iDLichHoc;
        }

        public string IDLopPhan { get; set; }
        public DateTime NgayHoc { get; set; }
        public int SoTiet { get; set; }
        public string PhongHoc { get; set; }
        public string GhiChu { get; set; }
        public string IDLichHoc { get; set; }
    }
}
