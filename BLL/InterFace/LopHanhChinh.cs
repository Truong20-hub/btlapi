using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.InterFace
{
    internal interface LopHanhChinh
    {
        void ThemLopHanhChinh(List<LopHanhChinh> lhc);
        void SuaLopHanhChinh(List<LopHanhChinh> lhc);
        void XoaLopHanhChinh(List<LopHanhChinh> lhc);
        void SearchLopHanhChinh(List<LopHanhChinh> lhc);
    }
}
