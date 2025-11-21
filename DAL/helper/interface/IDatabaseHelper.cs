using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;

namespace DAL.helper
{
    public class StoreParamesterInfo
    {
        public string storeProcedureName { get; set; }
        public List<Object> ListParamester { get; set; }
    }
    interface IDatabaseHelper
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
        string openConnectionTranpaction();
        ///<summary>
        /// sử dụng khi muốn thực thi cùng 1 lúc nhiều lệnh
        /// </summary>
        /// 
        string closeConnectionTranpaction(bool isRollbackTransaction);
        ///<summary>
        /// đong giao dịch
        /// </summary>
        /// 
        string ExcuteNonQuery(string query);
        ///<summary>
        /// Hmà này để thực thi câu truy vấn
        /// </summary>
        /// 
        DataTable ExcuteQueryToDataTable(string query,out string msgError);
        ///<summary>
        ///Hàm thực thi truy vấn trả về giá trị datatable
        /// </summary>
        /// 
        Object ExcuteScalar(string query,string msgError);
        ///<summary>
        /// hàm này thực thi truy vấn trả về 1 bản ghi
        /// </summary>
        /// 

        ///<summary>
        /// Thực thi truy vấn bằng structor procedure
        /// 
        /// </summary>
        /// 
        string ExcuteNonQueryProcedure(string proName, params object[] paramester);
        ///<summary>
        /// truy vấn không dữ liệu
        /// </summary>
        /// 
        DataTable ExcuteProcedureToDataTable(out string msgError, string proName, params object[] paramester); 
        ///<summary>
        ///Thực hiện truy vấn có trả về sữ liệu
        /// </summary>
        /// 
        DataSet ExcuteQueryToDataSet(string query,out string msgError,params object[] pra);
        ///<summary>
        /// hàm này để làm việc với nhiều bảng 1 lúc
        /// </summary>
        /// 

    }
}
