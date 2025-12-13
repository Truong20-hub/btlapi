using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BLL_.InterFace;
using Model_;
using DAL_;


namespace BLL_
{
    public partial class BLLKhoa:IkhoaBLL
    {
        private IKhoaRepostiry _khoa;
        public BLLKhoa(IKhoaRepostiry khoa)
        {
            _khoa = khoa;
        }
        public (bool k,string i) ThemKhoa(Khoa kh)
        {
            return _khoa.createKhoa(kh); 
        }
        public void SuaKhoa(List<IkhoaBLL> kh)
        {

        }
        public void XoaKhoa(List<IkhoaBLL> kh)
        {

        }
        public void SearchKhoa(List<IkhoaBLL> kh)
        {

        }
    }
}
