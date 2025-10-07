//+------------------------------------------------------------------+
//|                                                      Experts.mq5 |
//|                                            VantedgeTrading, 2025 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "VantedgeTrading, 2025"
#property link "https://www.mql5.com"
#property version "1.00"

#include "DevelopmentStrategy.mqh";

//------------ GLOBAL INPUTS ------------
input group "Global Settings";
input int ServerHourDifference = 2;
enum strategyChoice
{
   MACrossover = 1,
   MARetest = 2,
};
input strategyChoice StrategyChoice = MACrossover;

//------------ HourBreakout Initialization ------------
input group "HourBreakout Strategy Settings";
//#include "../../Include/VantedgeTrading/HourBreakout.mqh";
CStrategy *HourBreakoutStrategy;

//input int RangeBars_HourBreakout = 3;
//input int EntryHour_HourBreakout = 3;

// Create pointer to the selected strategy
CStrategy *activeStrategy;

int OnInit()
{
   // Set the static variable for all strategies
   CStrategy::SetServerHourDifference(ServerHourDifference);

   switch (StrategyChoice)
   {
   // MACROSSOVER INITIALIZATION
   case 1:
      //activeStrategy = new HourBreakout(RangeBars_HourBreakout, EntryHour_HourBreakout);
      if (activeStrategy != NULL)
      {
         Print("Strategy creation successfull.");
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
   if (activeStrategy != NULL)
   {
      delete activeStrategy;
      activeStrategy = NULL;
   }
}

void OnTick()
{
   activeStrategy.SetRisk(1);
   activeStrategy.ExecuteStrategy();
}
