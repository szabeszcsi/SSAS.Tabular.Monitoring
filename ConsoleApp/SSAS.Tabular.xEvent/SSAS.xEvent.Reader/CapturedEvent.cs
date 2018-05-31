using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SSAS.xEvent.Reader
{
    public class CapturedEvent
    {
        public DateTimeOffset TimeStampUtc { get; set; }
        public string EventType { get; set; }
        public string ServerName { get; set; }
        public string DatabaseName { get; set; }
        public string UserName { get; set; }
        public DateTime StartTime { get; set; }
        public int Duration { get; set; }
        public int CPUTime { get; set; }
        public string QueryText { get; set; }
        public string ObjectName { get; set; }
    }
}
