using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.InterFace
{
    internal interface PhongHoc
    {
        void ThemPhongHoc(List<PhongHoc> ph);
        void SuaPhongHoc(List<PhongHoc> ph);
        void XoaPhongHoc(List<PhongHoc> ph);
        void SearchPhongHoc(List<PhongHoc> ph);
    }
}
