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
         activeStrategy.Init();
         if (activeStrategy != NULL)
         {
            Print("HourBreakout creation successfull.");
            return (INIT_SUCCEEDED);
         }
         break;
         
      case 2:
         activeStrategy = new MiddleRange();
         activeStrategy.Init();
         if (activeStrategy != NULL)
         {
            Print("MiddleRange creation successfull.");
            return (INIT_SUCCEEDED);
         }
         break;
         
      case 3:
         activeStrategy = new MACrossover();
         activeStrategy.Init();
         if (activeStrategy != NULL)
         {
            Print("MACrossover creation successfull.");
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
   activeStrategy.ExecuteStrategy();
   
   if(RiskOverride != 0)
      activeStrategy.SetRisk(RiskOverride);
}
