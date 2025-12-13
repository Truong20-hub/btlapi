using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model_
{
    internal class DiemDanh
    {
        public DiemDanh(string iDDiemDanh, DateTime ngayDiemDanh, string iDSinhVien, string iDLichHoc, string trangThai)
        {
            IDDiemDanh = new Guid().ToString();
            NgayDiemDanh = ngayDiemDanh;
            IDSinhVien = iDSinhVien;
            IDLichHoc = iDLichHoc;
            TrangThai = trangThai;
        }

        public string IDDiemDanh { get; set; }
        public DateTime NgayDiemDanh { get; set; }
        public string IDSinhVien { get; set; }
        public string IDLichHoc { get; set; }
        public string TrangThai { get; set; }
    }
}
