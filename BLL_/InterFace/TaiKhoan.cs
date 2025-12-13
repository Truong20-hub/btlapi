using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.InterFace
{
    internal interface TaiKhoan
    {
        void ThemTaiKhoan(List<TaiKhoan> tk);
        void SuaTaiKhoan(List<TaiKhoan> tk);
        void XoaTaiKhoan(List<TaiKhoan> tk);
        void SearchTaiKhoan(List<TaiKhoan> tk);
    }
}
