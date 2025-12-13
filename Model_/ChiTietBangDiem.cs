using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model_
{
    internal class ChiTietBangDiem
    {
        public ChiTietBangDiem(string iDCT, string iDBD, string iDĐĐ, float diem)
        {
            IDCT = new Guid().ToString();
            IDBD = iDBD;
            IDĐĐ = iDĐĐ;
            Diem = diem;
        }

        public string IDCT { get; set; }
        public string IDBD { get; set; }
        public string IDĐĐ { get; set; }
        public float Diem { get; set; }
    }
}
