using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.InterFace
{
    internal interface ChiTietBangDiem
    {
        void ThemChiTietBangDiem(List<ChiTietBangDiem> ctbd);
        void SuaChiTietBangDiem(List<ChiTietBangDiem> ctbd);
        void XoaChiTietBangDiem(List<ChiTietBangDiem> ctbd);
        void SearchChiTietBangDiem(List<ChiTietBangDiem> ctbd);
    }
}
