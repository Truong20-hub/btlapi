using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model
{
    internal class LopHanhChinh
    {
        public LopHanhChinh(string iDLopHC, string tenLopHC, string khoaHoc, string nganhHoc, int siSo, List<SinhVien> danhSachSV)
        {
            IDLopHC = new Guid().ToString();
            TenLopHC = tenLopHC;
            KhoaHoc = khoaHoc;
            NganhHoc = nganhHoc;
            SiSo = siSo;
            DanhSachSV = danhSachSV;
        }

        public string IDLopHC { get; set; }
        public string TenLopHC { get; set; }
        public string KhoaHoc { get; set; }
        public string NganhHoc { get; set; }
        public int SiSo { get; set; }
        public List<SinhVien> DanhSachSV { get; set; }
    }
}
