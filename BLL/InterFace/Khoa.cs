using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.InterFace
{
    internal interface Khoa
    {
        void ThemKhoa(List<Khoa> kh);
        void SuaKhoa(List<Khoa> kh);
        void XoaKhoa(List<Khoa> kh);
        void SearchKhoa(List<Khoa> kh);
    }
}
