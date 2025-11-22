using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model
{
    internal class LichThi
    {
        public LichThi(string iDLopPhan, DateTime ngayThi, DateTime gioThi, string iDPhong, string phongHoc, string hinhThucThi, string giamThi)
        {
            IDLopPhan = new Guid().ToString();
            NgayThi = ngayThi;
            GioThi = gioThi;
            IDPhong = iDPhong;
            PhongHoc = phongHoc;
            HinhThucThi = hinhThucThi;
            GiamThi = giamThi;
        }

        public string IDLopPhan { get; set; }
        public DateTime NgayThi { get; set; }
        public DateTime GioThi { get; set; }
        public string IDPhong { get; set; }
        public string PhongHoc { get; set; }
        public string HinhThucThi { get; set; }
        public string GiamThi { get; set; }
    }
}
