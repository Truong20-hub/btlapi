using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model
{
    internal class PhongHoc
    {
        public PhongHoc(string iDPhongHoc, string tenPhongHoc, int sucChua, string trangThai)
        {
            IDPhongHoc = new Guid().ToString();
            TenPhongHoc = tenPhongHoc;
            SucChua = sucChua;
            TrangThai = trangThai;
        }

        public string IDPhongHoc { get; set; }
        public string TenPhongHoc { get; set; }
        public int SucChua { get; set; }
        public string TrangThai { get; set; }
    }
}
