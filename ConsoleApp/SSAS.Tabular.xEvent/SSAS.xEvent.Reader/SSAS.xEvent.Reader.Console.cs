using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using Microsoft.SqlServer.XEvent.Linq;
using System.Configuration;
using Microsoft.AnalysisServices.AdomdClient;
using System.Data;
using System.Xml;
using Serilog;

namespace SSAS.xEvent.Reader
{
    class Program
    {
        static void Main(string[] args)
        {
            Log.Logger = new LoggerConfiguration()
              .ReadFrom.AppSettings()
              .CreateLogger();

            string xSession = ConfigurationManager.AppSettings["xSessionName"];
            string ssasConnectionString = ConfigurationManager.AppSettings["ssasConnectionString"];
            string sqlConnectionString = ConfigurationManager.AppSettings["sqlConnectionString"];

            string sqlInsert = "INSERT INTO [dbo].[SSAS_Monitoring] ([TimeStampUtc],[EventType],[ServerName],[DatabaseName],[UserName],[StartTime],[Duration],[CPUTime],[QueryText],[ObjectName]) VALUES (@TimeStampUtc,@EventType,@ServerName,@DatabaseName,@UserName,@StartTime,@Duration,@CPUTime,@QueryText,@ObjectName)";

            try
            {
                Log.Information("SSAS xEvent reader started.");
                Log.Information("Establishing connection...");
                using (var connection = new AdomdConnection(ssasConnectionString))
                {
                    connection.Open();
                    Log.Information("Connected.");

                    Log.Information("Subscribing to xEvent stream session...");
                    using (var command = connection.CreateCommand())
                    {
                        command.CommandType = CommandType.Text;
                        command.CommandText =
                        "<Subscribe xmlns=\"http://schemas.microsoft.com/analysisservices/2003/engine\">" +
                            "<Object xmlns=\"http://schemas.microsoft.com/analysisservices/2003/engine\">" +
                                "<TraceID>" + xSession + "</TraceID>" +
                                "</Object>" +
                        "</Subscribe>";

                        Log.Information("Waiting for events to capture...");
                        using (var reader = XmlReader.Create(command.ExecuteXmlReader(), new XmlReaderSettings() { Async = true }))
                        using (var sqlConnection = new SqlConnection(sqlConnectionString))
                        using (var data = new QueryableXEventData(reader, EventStreamSourceOptions.EventStream, EventStreamCacheOptions.CacheToDisk))
                        {                            
                            foreach (PublishedEvent @event in data)
                            {
                                Log.Information($"Event captured: {@event.Name}");

                                CapturedEvent capturedEvent;
                                try
                                {
                                    capturedEvent = ConvertEvent(@event);
                                }
                                catch (ConvertEventException ex)
                                {
                                    Log.Error(ex, "Conversion error occured between publishedEvent - capturedEvent.");
                                    continue;
                                }                               

                                using(var sqlCommand = new SqlCommand())
                                {
                                    sqlCommand.Connection = sqlConnection;
                                    sqlCommand.CommandText = sqlInsert;
                                    sqlCommand.Parameters.AddWithValue("@TimeStampUtc", capturedEvent.TimeStampUtc);
                                    sqlCommand.Parameters.AddWithValue("@EventType", capturedEvent.EventType);
                                    sqlCommand.Parameters.AddWithValue("@ServerName", capturedEvent.ServerName);
                                    sqlCommand.Parameters.AddWithValue("@DatabaseName", capturedEvent.DatabaseName);
                                    sqlCommand.Parameters.AddWithValue("@UserName", capturedEvent.UserName);
                                    sqlCommand.Parameters.AddWithValue("@StartTime", capturedEvent.StartTime);
                                    sqlCommand.Parameters.AddWithValue("@Duration", capturedEvent.Duration);
                                    sqlCommand.Parameters.AddWithValue("@CPUTime", capturedEvent.CPUTime);
                                    sqlCommand.Parameters.AddWithValue("@QueryText", capturedEvent.QueryText);
                                    sqlCommand.Parameters.AddWithValue("@ObjectName", string.IsNullOrEmpty(capturedEvent.ObjectName) ? DBNull.Value : (object)capturedEvent.ObjectName);

                                    if(sqlConnection.State != ConnectionState.Open)
                                        sqlConnection.Open();

                                    sqlCommand.ExecuteNonQuery();

                                    if(sqlConnection.State == ConnectionState.Open)
                                        sqlConnection.Close();

                                    Log.Information($"Event ({@event.Name}) saved to database.");
                                }//eof using SqlCommand
                            }//eof foreach PublishedEvents
                        }//eof using xEventData
                    }//eof using command
                }//eof using ssasConnection
            }//eof try
            catch (AdomdConnectionException ex)
            {
                Log.Error(ex, "There was an error when connecting to SSAS.");
            }
            catch (AdomdErrorResponseException ex)
            {
                Log.Error(ex, "There was an unknown Adomd exception when connecting to SSAS.");
            }
            catch (AdomdException ex)
            {
                Log.Error(ex, "There was an unknown Adomd exception when connecting to SSAS.");
            }
            catch (XmlException ex)
            {
                Log.Error(ex, "There was an error with the XmlReader used in QueryableXEventData.");
            }
            catch (XEventException ex)
            {
                Log.Error(ex, "There was an xEvent exception.");
            }
            catch (ConvertEventException ex)
            {
                Log.Error(ex, "Conversion error occured between publishedEvent - capturedEvent.");
            }
            catch (SqlException ex)
            {
                Log.Error(ex, "There was an error when executing an SQL operation.");
            }

            catch (Exception ex)
            {
                Log.Error(ex, "An unhandled exception occured!");
            }
        }

        private static CapturedEvent ConvertEvent(PublishedEvent @event)
        {
            try
            {
                var capturedEvent = new CapturedEvent();

                capturedEvent.TimeStampUtc = @event.Timestamp;
                capturedEvent.EventType = @event.Name;
                capturedEvent.ServerName = @event.Fields["ServerName"].Value.ToString();
                capturedEvent.DatabaseName = @event.Fields["DatabaseName"].Value.ToString();
                capturedEvent.UserName = @event.Fields["NTCanonicalUserName"].Value.ToString();
                capturedEvent.StartTime = Convert.ToDateTime(@event.Fields["StartTime"].Value.ToString());
                capturedEvent.Duration = Convert.ToInt32(@event.Fields["Duration"].Value.ToString());
                capturedEvent.CPUTime = Convert.ToInt32(@event.Fields["CPUTime"].Value.ToString());
                capturedEvent.QueryText = @event.Fields["TextData"].Value.ToString();

                PublishedEventField objectNameField;
                @event.Fields.TryGetValue("ObjectName", out objectNameField);
                if (objectNameField != null)
                    capturedEvent.ObjectName = objectNameField.Value.ToString();

                return capturedEvent;
            }
            catch (Exception ex)
            {
                throw new ConvertEventException(ex);
            }          
        }
    }
}
