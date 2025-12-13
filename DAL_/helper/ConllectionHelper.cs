using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;

namespace DAL_.helper
{
    public static class ConvertMessage
    {
        private static readonly JsonSerializerSettings _Setting;
        static ConvertMessage()
        {
            _Setting = new JsonSerializerSettings()
            {
                Formatting = Formatting.None,
                NullValueHandling = NullValueHandling.Ignore,
                DateFormatHandling  = DateFormatHandling.IsoDateFormat,
                ContractResolver = new CamelCasePropertyNamesContractResolver(),
            };
            
        }
        static string SeriallizerObject(this object obj)
        {
            if(obj == null)
            {
                return "";
            }
            return JsonConvert.SerializeObject(obj, _Setting);
        }

    }
}
