using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.InterFace
{
    internal interface LopHocPhan
    {
        void ThemLopHocPhan(List<LopHocPhan> lhp);
        void SuaLopHocPhan(List<LopHocPhan> lhp);
        void XoaLopHocPhan(List<LopHocPhan> lhp);
        void SearchLopHocPhan(List<LopHocPhan> lhp);
    }
}
