using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model_;

namespace DAL_
{
    interface IAccountReponsive
    {
        NguoiDung GetbyMkTKTaiKhoan(string a,string b);
        NguoiDung getDatabyID(string id);
        bool create(NguoiDung account);
        bool update(NguoiDung account);
        bool delete(string id);
        List<NguoiDung>  Search(int pageIndex, int pageSize, out long total, string hoten, string taikhoan);

    }
}
