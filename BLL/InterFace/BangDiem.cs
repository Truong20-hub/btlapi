using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.InterFace
{
    internal interface BangDiem
    {
        void ThemBangDiem(List<BangDiem> bd);
        void SuaBangDiem(List<BangDiem> bd);
        void XoaBangDiem(List<BangDiem> bd);
        void SearchBangDiem(List<BangDiem> bd);
    }
}
