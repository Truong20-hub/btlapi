using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.InterFace
{
    internal interface GiangVien
    {
        void ThemGiangVien(List<GiangVien> gv);
        void SuaGiangVien(List<GiangVien> gv);
        void XoaGiangVien(List<GiangVien> gv);
        void SearchGiangVien(List<GiangVien> gv);
    }
}
