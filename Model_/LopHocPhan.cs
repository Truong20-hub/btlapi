using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model_
{
    internal class LopHocPhan
    {
        public LopHocPhan(string tenLop, string iDHocPhan, string iDMonHoc, string giangVienPhuTrach, DateTime thoiGianMo, DateTime thoiGianDong, int soLuongSinhVien, string thuTuUuTien)
        {
            TenLop = tenLop;
            IDHocPhan = new Guid().ToString();
            IDMonHoc = iDMonHoc;
            GiangVienPhuTrach = giangVienPhuTrach;
            ThoiGianMo = thoiGianMo;
            ThoiGianDong = thoiGianDong;
            SoLuongSinhVien = soLuongSinhVien;
            ThuTuUuTien = thuTuUuTien;
        }

        public string TenLop { get; set; }
        public string IDHocPhan { get; set; }
        public string IDMonHoc { get; set; }
        public string GiangVienPhuTrach { get; set; }
        public DateTime ThoiGianMo { get; set; }
        public DateTime ThoiGianDong { get; set; }
        public int SoLuongSinhVien { get; set; }
        public string ThuTuUuTien { get; set; }
    }
}
