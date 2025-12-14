//+------------------------------------------------------------------+
//|                                                      Experts.mq5 |
//|                                            VantedgeTrading, 2025 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "VantedgeTrading, 2025"
#property link "https://www.mql5.com"
#property version "1.00"

#include "../../Include/VantedgeTrading/Portfolio Strategies/Strategy.mqh";

//------------ GLOBAL INPUTS ------------
input group "Account Settings";
enum challengePhase
{
   Challenge=1,
   Verification=2,
   Funded=3,
   Null=4,
}; 
input challengePhase ChallengePhase = Challenge;
enum strategyChoice
{
   HourBreakout_Strategy = 1,
   MiddleRange_Strategy  = 2,
   MACrossover_Strategy  = 3
};
input strategyChoice StrategyChoice = HourBreakout_Strategy;

input int ServerHourDifference = 2;
input double RiskOverride = 0.0;

#include "../../Include/VantedgeTrading/Portfolio Strategies/HourBreakout.mqh";
CStrategy *HourBreakoutStrategy;
#include "../../Include/VantedgeTrading/Portfolio Strategies/MiddleRange.mqh";
CStrategy *MiddleRangeStrategy;
#include "../../Include/VantedgeTrading/Portfolio Strategies/MACrossover.mqh";
CStrategy *MACrossoverStrategy;

// Create pointer to the selected strategy
CStrategy *activeStrategy;

int OnInit()
{
   // Set the static variable for all strategies
   CStrategy::SetServerHourDifference(ServerHourDifference);

   switch (StrategyChoice)
   {
      case 1:
         activeStrategy = new HourBreakout();
         break;
         
      case 2:
         activeStrategy = new MiddleRange();
         break;
         
      case 3:
         activeStrategy = new MACrossover();
         break;

      default:
         Print("Strategy initialization failed.");
         return INIT_FAILED;
         break;
   }
   
   if(activeStrategy == NULL)
      return INIT_FAILED;
   
   if(!activeStrategy.Init())
      return INIT_FAILED;
      
   if(!activeStrategy.IsCorrectTimeframe())
   {
      PrintFormat(
      "Strategy requires %s timeframe, but chart is %s", 
      EnumToString(activeStrategy.RequiredTimeframe()),
      EnumToString(_Period)
      );
      
      return INIT_FAILED;
   }
   
   return INIT_SUCCEEDED;
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
   activeStrategy.ExecuteStrategy();
   
   if(RiskOverride != 0)
      activeStrategy.SetRisk(RiskOverride);
}
