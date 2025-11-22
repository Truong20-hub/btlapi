using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.InterFace
{
    internal interface LichHoc
    {
        void ThemLichHoc(List<LichHoc> lichhoc);
        void SuaLichHoc(List<LichHoc> lichhoc);
        void XoaLichHoc(List<LichHoc> lichhoc);
        void SearchLichHoc(List<LichHoc> lichhoc);
    }
}
