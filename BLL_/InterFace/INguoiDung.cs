using Model_;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL_.InterFace
{
    public interface INguoiDung
    {
        NguoiDung GetbyMkTKTaiKhoan(string a,string b);
        NguoiDung getDatabyID(string id);
        bool create(NguoiDung account);
        bool update(NguoiDung account);
        bool delete(string id);
        List<NguoiDung> Search(int pageIndex, int pageSize, out long total, string hoten, string taikhoan);
    }
}
