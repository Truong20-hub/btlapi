using Microsoft.Data.SqlClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using System.Data;

namespace DAL_.helper
{
    public class DatabaseHelper:IDatabaseHelper
    {
        public string stringConllection { get; set; }
        public SqlConnection sqlConnect { get; set; }
        public SqlTransaction SqlTran { get; set; }
        public DatabaseHelper(IConfiguration configuration)
        {
            stringConllection = configuration["ConnectionStrings:DefaultConnection"];
        }
        public void setConnection(string connectionString)
        {
            connectionString = stringConllection;
        }
        public string openConnection()
        {
            try
            {
                if (sqlConnect == null)
                    sqlConnect = new SqlConnection(stringConllection);
                sqlConnect.Open();
                return "";
            }
            catch(Exception ex) 
            { 
                return ex.Message;
            }
        }
        public string closeConnection()
        {
            try
            {
                if(sqlConnect != null && sqlConnect.State != ConnectionState.Closed)
                {
                    sqlConnect.Close();
                   
                }
                return "";
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }
        public string ExcuteNonQueryProcedure(string proName, params object[] parameters)
        {
            string result = "";

            using (SqlConnection sqlConnection = new SqlConnection(stringConllection))
            {
                sqlConnection.Open();

                using (SqlTransaction tran = sqlConnection.BeginTransaction())
                {
                    try
                    {
                        using (SqlCommand cmd = new SqlCommand(proName, sqlConnection, tran))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;

                            int count = parameters.Length / 2;
                            int index = 0;

                            for (int i = 0; i < count; i++)
                            {
                                string paramName = Convert.ToString(parameters[index++]);
                                object value = parameters[index++];
                                if (paramName == "@Result")
                                {
                                    var outParam = new SqlParameter(paramName, SqlDbType.Int)
                                    {
                                        Direction = ParameterDirection.Output
                                    };

                                    cmd.Parameters.Add(outParam);

                                    continue;  // << MUST HAVE (để không Add thêm lần nữa)


                                }
                                if (paramName.ToLower().Contains("json"))
                                {
                                    cmd.Parameters.Add(new SqlParameter()
                                    {
                                        ParameterName = paramName,
                                        Value = value ?? DBNull.Value,
                                        SqlDbType = SqlDbType.NVarChar
                                    });
                                }
                                else
                                {
                                    cmd.Parameters.AddWithValue(paramName, value ?? DBNull.Value);
                                }
                            }

                            cmd.ExecuteNonQuery();
                            string a =  cmd.Parameters["@Result"].Value.ToString();
                            result = a;
                        }

                        tran.Commit();
                    }
                    catch (Exception ex)
                    {
                        result = ex.ToString();
                        try { tran.Rollback(); } catch { }
                    }
                }
            }

            return result;
        }

    }

}
