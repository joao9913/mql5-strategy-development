//+------------------------------------------------------------------+
//|                                                      Experts.mq5 |
//|                                            VantedgeTrading, 2025 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "VantedgeTrading, 2025"
#property link "https://www.mql5.com"
#property version "1.00"

#include "../../Include/VantedgeTrading/Strategy.mqh"

//------------ GLOBAL INPUTS ------------
input group "Global Settings";
input int ServerHourDifference = 2;
enum strategyChoice
{
   HourBreakout_Strategy = 1,
   MiddleRange_Strategy = 2,
};
input strategyChoice StrategyChoice = HourBreakout_Strategy;

//------------ HourBreakout Initialization ------------
input group "HourBreakout Strategy Settings";
#include "../../Include/VantedgeTrading/HourBreakout.mqh";
CStrategy *HourBreakoutStrategy;

input int RangeBars_HourBreakout = 3;
input int EntryHour_HourBreakout = 3;

//------------ MiddleRange Initialization ------------
input group "MiddleRange Strategy Settings";
#include "../../Include/VantedgeTrading/MiddleRange.mqh";
CStrategy *MiddleRangeStrategy;

input int RangeBars_MiddleRange = 3;
input int EntryHour_MiddleRange = 4;
input int EntryMinute_MiddleRange = 30;

// Create pointer to the selected strategy
CStrategy *activeStrategy;

int OnInit()
{
   // Set the static variable for all strategies
   CStrategy::SetServerHourDifference(ServerHourDifference);

   switch (StrategyChoice)
   {
   // HOURBREAKOUT INITIALIZATION
   case 1:
      // Create HourBreakout object
      activeStrategy = new HourBreakout(RangeBars_HourBreakout, EntryHour_HourBreakout);
      if (activeStrategy != NULL)
      {
         Print("HourBreakout Strategy creation successfull.");
         return (INIT_SUCCEEDED);
      }
      break;

   // MIDDLERANGE INITIALIZATION
   case 2:
      // Create MiddleRange object
      activeStrategy = new MiddleRange(RangeBars_MiddleRange, EntryHour_MiddleRange, EntryMinute_MiddleRange);
      if (activeStrategy != NULL)
      {
         Print("MiddleRange Strategy creation successfull.");
         return (INIT_SUCCEEDED);
      }
      break;

   default:
      Print("Strategy initialization failed.");
      return (INIT_FAILED);
      break;
   }

   return (INIT_FAILED);
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
   activeStrategy.ExecuteStrategy();
}
