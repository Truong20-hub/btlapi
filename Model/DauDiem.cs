using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model
{
    internal class DauDiem
    {
        public DauDiem(string iDĐĐ, string tenĐĐ, float heSoDiem, string loaiDiem, string moTa)
        {
            IDĐĐ = new Guid().ToString();
            TenĐĐ = tenĐĐ;
            HeSoDiem = heSoDiem;
            LoaiDiem = loaiDiem;
            MoTa = moTa;
        }

        public string IDĐĐ { get; set; }
        public string TenĐĐ{ get; set; }
        public float HeSoDiem { get; set; }
        public string LoaiDiem { get; set; }
        public string MoTa { get; set; }
    }
}
