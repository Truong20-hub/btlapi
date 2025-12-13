using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.InterFace
{
    internal interface LichThi
    {
        void ThemLichThi(List<LichThi> lt);
        void SuaLichThi(List<LichThi> lt);
        void XoaLichThi(List<LichThi> lt);
        void SearchLichThi(List<LichThi> lt);
    }
}
