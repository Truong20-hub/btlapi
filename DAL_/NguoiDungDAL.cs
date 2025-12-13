using DAL_.helper;
using Model_;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL_
{
    
    public class NguoiDungDAL:IAccountReponsive
    {
        private IDatabaseHelper databaseHelper;
        public NguoiDungDAL(IDatabaseHelper databaseHelper)
        {
            this.databaseHelper = databaseHelper;
        }
        public NguoiDung GetbyMkTKTaiKhoan(NguoiDung Nd)
        {
            NguoiDung tk = new NguoiDung();
            string t = "";
            bool k = true;
            try
            {
                var result = databaseHelper.ExcuteProcedureToDataTable(out t, "sp_SearchNguoiDung",
                    "@MaNguoiDung", Nd.Id,
                    "@MatKhau", Nd.MatKhau,
                    "@SDT", Nd.SDT,
                    "@Email", Nd.email,
                    "@Loai", Nd.loai,
                    "@DiaChi", Nd.DiaChi
                );
                if (result.Rows.Count > 1)
                {
                    DataRow row = result.Rows[0];
                    tk.Id = Guid.Parse( row["MaNguoiDung"].ToString());
                    tk.MatKhau = row["MatKhau"].ToString();
                    tk.SDT = row["SDT"] != DBNull.Value ? row["SDT"].ToString() : "";
                    tk.email = row["Email"] != DBNull.Value ? row["Email"].ToString() : "";
                    tk.DiaChi = row["DiaChi"] != DBNull.Value ? row["DiaChi"].ToString() : "";
                    tk.loai = row["Loai"] != DBNull.Value ? Convert.ToInt32(row["Loai"]) : 0;
                }
            }
            catch (Exception ex)
            {
                throw new Exception(t, ex);
            }
            return tk;
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
