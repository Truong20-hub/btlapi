using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model_;

namespace DAL_
{
    public interface IKhoaRepostiry
    {
        (bool k, string i) createKhoa(Khoa khoa);
        List<Khoa> getAllKhoa();

        bool updateKhoa(Khoa khoa);
        bool deleteKhoa(string id);
        List<Khoa> search(string id); // tìm kiếm theo mã khoa
        List<Khoa> Search_ten(string name);
    }
}
