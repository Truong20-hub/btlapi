using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;

namespace DAL_.helper
{
    public class StoreParamesterInfo
    {
        public string storeProcedureName { get; set; }
        public List<Object> ListParamester { get; set; }
    }
    public interface IDatabaseHelper
    {
        void setConnection(string connectionString);
        ///<sumary>
        ///thiết lập chuỗi kết nối
        /// / //
        string openConnection();
        ///<summary>
        ///mở kết nối
        /// </summary>///
        string closeConnection();
        ///<summary>
        ///đóng kết nối
        /// 
        /// </summary>
        //string openConnectionTranpaction();
        /////<summary>
        ///// sử dụng khi muốn thực thi cùng 1 lúc nhiều lệnh
        ///// </summary>
        ///// 
        //string closeConnectionTranpaction(bool isRollbackTransaction);
        /////<summary>
        ///// đong giao dịch
        ///// </summary>
        ///// 
        //string ExcuteNonQuery(string query);
        /////<summary>
        ///// Hmà này để thực thi câu truy vấn
        ///// </summary>
        ///// 
        //DataTable ExcuteQueryToDataTable(string query,out string msgError);
        /////<summary>
        /////Hàm thực thi truy vấn trả về giá trị datatable
        ///// </summary>
        ///// 
        //Object ExcuteScalar(string query,string msgError);
        /////<summary>
        ///// hàm này thực thi truy vấn trả về 1 bản ghi
        ///// </summary>
        ///// 

        /////<summary>
        ///// Thực thi truy vấn bằng structor procedure
        ///// 
        ///// </summary>
        ///// 
        string ExcuteNonQueryProcedure(string proName, params object[] paramester);
        /////<summary>
        ///// truy vấn không dữ liệu
        ///// </summary>
        ///// 
        DataTable ExcuteProcedureToDataTable(out string msgError, string proName, params object[] paramester);
        DataTable ExcuteProcedureToDataTable(string proName);
        /////<summary>
        /////Thực hiện truy vấn có trả về sữ liệu
        ///// </summary>
        ///// 
        //DataSet ExcuteQueryToDataSet(string query,out string msgError,params object[] pra);
        /////<summary>
        ///// hàm này để làm việc với nhiều bảng 1 lúc
        ///// </summary>
        ///// 
        //string ExcuteQueryWithTranSacTion(string query, out string msgError, params object[] pra);
        /////<summary>
        /////hàm này để triển khai nhiều câu lệnh cùng lúc như là insert,update,delete và cùng trả về 1 kết quả
        ///// </summary>
        ///// 
        //List<string> ExcuteQueryScalarProcedure(List<StoreParamesterInfo> info);
        /////<summary>
        ///// Hàm này dùng để triển khai nhiều proceduce cùng lúc và mỗi một structer trả về 1 giá trị duy nhất
        ///// </summary>
        ///// 
        //object ExcuteScalarProcedure(out string msgError,string query, params object[] pra);
        /////<summary>
        ///// hàm này dùng để trả về 1 giá trị duy nhất có thể dùng đẻ trả về bất cứ giá trị nào
        ///// </summary>
        ///// 
        //object ExcuteScalarProcedureWithTransaction(out string msgError, string query, params object[] pra);
        /////<summary>
        ///// hàm này để truy vấn 1 lúc nhiều hành động à trả về 1 giá trị duy nhất nhưng có thể là bất cứ dữ liệu nào
        ///// </summary>
        ///// 
        //List<Object> ExcuteScalarProcedure(List<string> msgError, List<StoreParamesterInfo> storeParamesterInfos);
        /////<summary>
        ///// hàm này để truy vấn nhieeuf lệnh truy vấn và trả ra nhiều giá trị và có nhiều object ko liên quan vs nhau
        ///// </summary>
        ///// 
        //List<Object> ExcuteScalarProcedureWithTransaction(List<string> msgError, List<StoreParamesterInfo> storeParamesterInfos);
        /////<summary>
        ///// Hàm này thực hiện nhiều truy vấn cùng 1 lúc dùng để khi lm được 1 nửa nếu không lm nữa thì các cái khác trước đó cũng bị xóa
        ///// </summary>
        ///// 
        //List<Object> ReturnValuesFromExecuteSProcedure(out string msgError, string sprocedureName, int outputParamCountNumber, params object[] paramObjects);
        /////<summary>
        ///// hàm này có thể trả ra số output theo yêu cầu
        ///// </summary>
        ///// 

    }
}
