using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.InterFace
{
    internal interface DauDiem
    {
        void ThemDauDiem(List<DauDiem> daudiem);
        void SuaDauDiem(List<DauDiem> daudiem);
        void XoaDauDiem(List<DauDiem> daudiem);
        void SearchDauDiem(List<DauDiem> daudiem);
    }
}
