//+------------------------------------------------------------------+
//|                                                   WriteToCSV.mqh |
//|                                         Copyright 2025, YourName |
//|                                                 https://mql5.com |
//| 20.09.2025 - Initial release                                     |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, YourName"
#property link "https://mql5.com"

// Get local PC time
#import "kernel32.dll"
   void GetLocalTime(ushort &arr[]);
#import

class CWriteToCSV
{
private:

   //Core parameters
   string m_filename;
   
public:

   //Constructor
   CWriteToCSV(string filename = "Simulation Mode")
   {  
      ushort t[8];
      GetLocalTime(t);
      string localTime = StringFormat("%04d.%02d.%02d_%02d-%02d-%02d",
                                      t[0], t[1], t[3], t[4], t[5], t[6]);

      m_filename = "SimulationData\\" + filename + localTime;
      StringReplace(m_filename, ":", "-");
      StringReplace(m_filename, " ", "_");
      m_filename += ".csv";
      
      Init();
   }
   
   //Write simulation data to CSV file
   void WriteCSV(string &data[])
   {
      int handle = FileOpen(m_filename, FILE_READ | FILE_WRITE | FILE_CSV | FILE_COMMON | FILE_UNICODE);
      if(handle == INVALID_HANDLE)
      {
         Print("Error opening file for append: ", m_filename, " | Error: ", GetLastError());
         return;
      }
   
      // Move cursor to end of file before writing
      FileSeek(handle, 0, SEEK_END);
      
      string challengeNumber = data[0];
      string startTime = data[1];
      string endTime = data[2];
      string phase = data[3];
      string outcome = data[4];
      string reason = data[5];
      string duration = data[6];
      string startBalance = data[7];
      string endBalance = data[8];
      string maxDrawdown = data[9];
      string profitTarget = data[10];
      string maxDailyDrawdown = data[11];
      
      
      FileWrite(handle, 
         challengeNumber,
         startTime,
         endTime,
         phase,
         outcome,
         reason,
         duration,
         startBalance,
         endBalance,
         maxDrawdown,
         profitTarget,
         maxDailyDrawdown);
      FileClose(handle);
   }
   
   //Create CSV File
   bool Init()
   {        
      int handle = FileOpen(m_filename, FILE_WRITE | FILE_CSV | FILE_COMMON | FILE_UNICODE);
      if(handle == INVALID_HANDLE)
      {
         Print("Error creating file ", m_filename, " Error: ", GetLastError());
         return false;
      }
      
      FileWrite(handle, "Challenge Number", 
                        "Start Phase Date", 
                        "End Phase Date",
                        "Phase", 
                        "Outcome",
                        "Reason",
                        "Duration",
                        "Start Balance",
                        "Ending Balance",
                        "Max Drawdown",
                        "Profit Target",
                        "Daily Drawdown");
      FileClose(handle);
      return true;
   }
};