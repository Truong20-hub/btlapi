using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.InterFace
{
    internal interface MonHoc
    {
        void ThemMonHoc(List<MonHoc> mh);
        void SuaMonHoc(List<MonHoc> mh);
        void XoaMonHoc(List<MonHoc> mh);
        void SearchMonHoc(List<MonHoc> mh);
    }
}
