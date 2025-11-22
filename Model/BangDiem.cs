using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model
{
    internal class BangDiem
    {
        public BangDiem(string iDBD, string iDSinhVien, string iDMonHoc, string khoaHoc)
        {
            IDBD = new Guid().ToString();
            IDSinhVien = iDSinhVien;
            IDMonHoc = iDMonHoc;
            KhoaHoc = khoaHoc;
        }

        public string IDBD { get; set; }
        public string IDSinhVien { get; set; }
        public string IDMonHoc { get; set; }
        public string KhoaHoc { get; set; }
    }
}
