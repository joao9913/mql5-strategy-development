//+------------------------------------------------------------------+
//|                                                      Experts.mq5 |
//|                                            VantedgeTrading, 2025 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "VantedgeTrading, 2025"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "..\Include\Strategy.mqh"
#include "..\Include\HourBreakout.mqh"

//Pointer to Strategy
CStrategy* hourBreakout;

//Dummy inputs to test the strategy HourBreakout
input int NBars = 3;
input int EntryHour = 3;

int OnInit()
{
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
   hourBreakout.ExecuteTrade();
}
