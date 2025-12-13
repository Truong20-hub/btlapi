using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.InterFace
{
    internal interface LopHoc
    {
        void ThemLH(List<LopHoc> lh);
        void SuaLH(List<LopHoc> lh);
        void XoaLH(List<LopHoc> lh);
        void SearchLH(List<LopHoc> lh);
    }
}
