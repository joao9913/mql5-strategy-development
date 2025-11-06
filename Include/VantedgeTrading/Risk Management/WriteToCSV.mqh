//+------------------------------------------------------------------+
//|                                                   WriteToCSV.mqh |
//|                                         Copyright 2025, YourName |
//|                                                 https://mql5.com |
//| 20.09.2025 - Initial release                                     |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, YourName"
#property link "https://mql5.com"

class CWriteToCSV
{
private:

   //Core parameters
   string m_filename;
   
public:

   //Constructor
   CWriteToCSV(string filename = "SimulationData_")
   {
      m_filename = filename + TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES);
      StringReplace(m_filename, ":", "-");
      StringReplace(m_filename, " ", "_");
      m_filename += ".csv";
   }
   
   //Create CSV File
   bool Init()
   {      
      //Open in write mode - overwrite existing file
      int handle = FileOpen(m_filename, FILE_WRITE | FILE_CSV);
      if(handle == INVALID_HANDLE)
      {
         Print("Error creating file ", m_filename, " Error: ", GetLastError());
         return false;
      }
      
      //Write header row
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
      
      Print("CSV file created with header: ", m_filename);
      return true;
   }
};