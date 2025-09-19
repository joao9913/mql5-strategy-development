//+------------------------------------------------------------------+
//|                                                      Experts.mq5 |
//|                                            VantedgeTrading, 2025 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "VantedgeTrading, 2025"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "..\..\Include\VantedgeTrading\Strategy.mqh"

//------ HourBreakout Initialization ------------

#include "..\..\Include\VantedgeTrading\HourBreakout.mqh"
CStrategy* hourBreakout;

input int NBars = 3;
input int EntryHour = 3;
input int ServerHourDifference = 2;

int OnInit()
{
   // Set the static variable for all strategies
    CStrategy::SetServerHourDifference(ServerHourDifference);
    
   //Create HourBreakout object
   hourBreakout = new HourBreakout(NBars, EntryHour);
   if(hourBreakout == NULL)
   {
      Print("Strategy creation failed.");
      return (INIT_FAILED);
   }
   
   Print("Strategy created successfully.");
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   
}
  
void OnTick()
{
   hourBreakout.ExecuteStrategy();
}
