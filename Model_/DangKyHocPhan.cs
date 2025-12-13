using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model_
{
    internal class DangKyHocPhan
    {
        public DangKyHocPhan(string iDMonHoc, DateTime ngayDK, string trangThaiDK)
        {
            IDMonHoc =new Guid().ToString();
            NgayDK = ngayDK;
            TrangThaiDK = trangThaiDK;
        }

        public string IDMonHoc { get; set; }
        public DateTime NgayDK { get; set; }
        public string TrangThaiDK { get; set; }
    }
}
