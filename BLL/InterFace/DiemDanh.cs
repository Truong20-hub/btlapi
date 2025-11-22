using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.InterFace
{
    internal interface DiemDanh
    {
        void ThemDiemDanh(List<DiemDanh> diemdanh);
        void SuaDiemDanh(List<DiemDanh> diemdanh);
        void XoaDiemDanh(List<DiemDanh> diemdanh);
        void SearchDiemDanh(List<DiemDanh> diemdanh);
    }
}
