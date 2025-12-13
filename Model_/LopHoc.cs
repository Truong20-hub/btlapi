using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model_
{
    internal class LopHoc
    {
        public LopHoc(string iDLop, string tenLop, string giaoVienPhuTrach)
        {
            IDLop = new Guid().ToString();
            TenLop = tenLop;
            GiaoVienPhuTrach = giaoVienPhuTrach;
        }

        public string IDLop { get; set; }
        public string TenLop { get; set; }
        public string GiaoVienPhuTrach { get; set; }
    }
}
