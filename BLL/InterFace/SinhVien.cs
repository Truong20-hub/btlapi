using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.InterFace
{
    internal interface SinhVien
    {
        void ThemSV(List<SinhVien> sv);
        void SuaSV(List<SinhVien> sv);
        void XoaSV(List<SinhVien> sv);
        void SearchSV(List<SinhVien> sv);
    }
}
