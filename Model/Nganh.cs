using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model
{
    internal class Nganh
    {
        public Nganh(string iDNganh, string tenNganh, string maKhoa, string trinhDoDaoTao, int soTinChi)
        {
            IDNganh = new Guid().ToString();
            TenNganh = tenNganh;
            MaKhoa = maKhoa;
            TrinhDoDaoTao = trinhDoDaoTao;
            SoTinChi = soTinChi;
        }

        public string IDNganh { get; set; }
        public string TenNganh { get; set; }
        public string MaKhoa { get; set; }
        public string TrinhDoDaoTao { get; set; }
        public int SoTinChi { get; set; }
    }
}
