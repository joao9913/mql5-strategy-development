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
   CWriteToCSV(string filename = "SimulationData_")
   {  
      ushort t[8];
      GetLocalTime(t);
      string localTime = StringFormat("%04d.%02d.%02d_%02d-%02d-%02d",
                                      t[0], t[1], t[3], t[4], t[5], t[6]);

      
      m_filename = filename + localTime;
      StringReplace(m_filename, ":", "-");
      StringReplace(m_filename, " ", "_");
      m_filename += ".csv";
   }
   
   //Write simulation data to CSV file
   
   //Create CSV File
   bool Init()
   {      
      string path = "SimulationData\\";      
      int handle = FileOpen(path + m_filename, FILE_WRITE | FILE_CSV | FILE_COMMON);
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
      
      Print("Common path: ", TerminalInfoString(TERMINAL_COMMONDATA_PATH));
      return true;
   }
};