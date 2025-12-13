using DAL_.helper;
using Model_;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL_
{
    public class KhoaDAL:IKhoaRepostiry
    {
        private IDatabaseHelper helper;
        public KhoaDAL(IDatabaseHelper _helper)
        {
            this.helper = _helper;
        }
        public (bool k, string i) createKhoa(Khoa khoa)
        {
            bool k = false;
            string msg = "";
            try
            {
                var result = helper.ExcuteNonQueryProcedure("sp_ThemKhoa",
                             "@MaKhoa", khoa.IDKhoa,
                             "@TenKhoa", khoa.TenKhoa,
                             "@SDT", khoa.SDT,
                                "@Email", khoa.Email,
                                "@TruongKhoa", khoa.TruongKhoa,
                                "@Result", 0

                );
                
                if(result == "1")
                {
                    k = false;
                    msg = "mã khoa đã tồn tại";
                    return (k, msg);
                }
                else if(result == "2")
                {

                    k = false;
                    msg = "GIảng viên ko tồn tại";
                    return (k, msg);
                }
                k = true;
                msg = "Thêm thành công";
                return (k, msg);


            }
            catch (Exception ex) { 
                throw ex;
            }
            
        }
        public List<Khoa> getAllKhoa()
        {
            List<Khoa> khoas = new List<Khoa>();
            return khoas;
        }

        public bool updateKhoa(Khoa khoa)
        {
            return true;
        }
        public bool deleteKhoa(string id)
        {
            return true;
        }
        public List<Khoa> search(string id)
        {
            return new List<Khoa>();
        } // tìm kiếm theo mã khoa
        public List<Khoa> Search_ten(string name)
        {
            return new List<Khoa>();
        }
    }
}
