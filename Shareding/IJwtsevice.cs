using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shareding
{
    public interface IJwtsevice
    {
        string GenerateToken(string username, string role);
    }
}
