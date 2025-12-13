using BLL_.InterFace;
using DAL_;
using DAL_.helper;
using Model_;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL_
{
    public class BLLNguoiDung:INguoiDung
    {
        NguoiDungDAL dAL;
        public NguoiDung GetbyMkTKTaiKhoan(NguoiDung Nd)
        {
            return dAL.GetbyMkTKTaiKhoan(Nd);
        }
        public NguoiDung getDatabyID(string id)
        {
            NguoiDung tk = new NguoiDung();
            return tk;
        }
        public bool create(NguoiDung account)
        {
            return true;
        }
        public bool update(NguoiDung account)
        {
            return true;
        }
        public bool delete(string id)
        {
            return true;
        }
        public List<NguoiDung> Search(int pageIndex, int pageSize, out long total, string hoten, string taikhoan)
        {
            total = 0;
            List<NguoiDung> taiKhoans = new List<NguoiDung>() { };
            return taiKhoans;

        }
    }
}
