using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SSAS.xEvent.Reader
{
    public class ConvertEventException : Exception
    {
        public ConvertEventException(Exception ex):base($"There was an error when converting PublishedEvent to CapturedEvent: {ex.Message} ", ex)
        {            
        }
    }
}
