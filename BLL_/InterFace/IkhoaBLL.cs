using Model_;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL_.InterFace
{
    public interface IkhoaBLL
    {
        (bool k, string i) ThemKhoa(Khoa kh);
        void SuaKhoa(List<IkhoaBLL> kh);
        void XoaKhoa(List<IkhoaBLL> kh);
        void SearchKhoa(List<IkhoaBLL> kh);
    }
}
