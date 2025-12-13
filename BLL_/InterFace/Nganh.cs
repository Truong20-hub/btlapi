using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.InterFace
{
    internal interface Nganh
    {
        void ThemNganh(List<Nganh> ng);
        void SuaNganh(List<Nganh> ng);
        void XoaNganh(List<Nganh> ng);
        void SearchNganh(List<Nganh> ng);
    }
}
