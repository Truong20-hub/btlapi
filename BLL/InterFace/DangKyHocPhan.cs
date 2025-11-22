using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.InterFace
{
    internal interface DangKyHocPhan
    {
        void DangKy(List<DangKyHocPhan> dkhp);
        void XoaDangKyHocPhan(List<DangKyHocPhan> dkhp);
    }
}
