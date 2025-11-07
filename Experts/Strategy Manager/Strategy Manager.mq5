//+------------------------------------------------------------------+
//|                                                      Experts.mq5 |
//|                                            VantedgeTrading, 2025 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "VantedgeTrading, 2025"
#property link "https://www.mql5.com"
#property version "1.00"

#include "../../Include/VantedgeTrading/Trading Strategies/Strategy.mqh";
#include "../../Include/VantedgeTrading/Risk Management/PropFirm Simulation.mqh";
#include "../../Include/VantedgeTrading/Risk Management/Edge Risk Scaling.mqh";

//------------ GLOBAL INPUTS ------------
input group "Global Settings";
input int ServerHourDifference = 2;
input bool UseCompounding = false;
input int StartingAccountBalance = 10000;
input double RiskOverride = 1;
enum strategyChoice
{
   HourBreakout_Strategy = 1,
   MiddleRange_Strategy = 2,
   MARetest_Strategy = 3,
   MACrossover_Strategy = 4,
   OffsetMA_Strategy = 5,
};
input strategyChoice StrategyChoice = HourBreakout_Strategy;

//------------ SIMULATION SETTINGS ------------
input group "Simulation Settings";
input bool RunSimulation = true;
input SimulationMode PhaseRun = MODE_PHASE_1;

//+------------------------------------------------------------------+
//|                     HourBreakout Initialization                  |
//+------------------------------------------------------------------+
#include "../../Include/VantedgeTrading/Trading Strategies/HourBreakout.mqh";
CStrategy *HourBreakoutStrategy;
input group "HourBreakout Strategy Settings";
input int RangeBars_HourBreakout = 3;
input int EntryHour_HourBreakout = 3;

//+------------------------------------------------------------------+
//|                     MiddleRange  Initialization                  |
//+------------------------------------------------------------------+
#include "../../Include/VantedgeTrading/Trading Strategies/MiddleRange.mqh";
CStrategy *MiddleRangeStrategy;
input group "MiddleRange Strategy Settings";
input int RangeBars_MiddleRange = 3;
input int EntryHour_MiddleRange = 4;
input int EntryMinute_MiddleRange = 30;

//+------------------------------------------------------------------+
//|                     MA Retest Initialization                     |
//+------------------------------------------------------------------+
#include "../../Include/VantedgeTrading/Trading Strategies/MARetest.mqh"
CStrategy *MARetestStrategy;
input group "MA Retest Strategy Settings";
input int MAPeriod_MARetest = 3;
input int Lookback_MARetest = 4;
input int ATRMultiplier_MARetest = 30;

//+------------------------------------------------------------------+
//|                     MA Crossover Initialization                  |
//+------------------------------------------------------------------+
#include "../../Include/VantedgeTrading/Trading Strategies/MACrossover.mqh"
CStrategy *MACrossoverStrategy;
input group "MA Crossover Strategy Settings";
input int ShortMAPeriod_MACRossover = 3;
input int LongMAPeriod_MACRossover = 4;
input int Lookback_MACRossover = 30;
input int ATRMultiplier_MACRossover = 30;

//+------------------------------------------------------------------+
//|                     Offset MA Initialization                     |
//+------------------------------------------------------------------+
#include "../../Include/VantedgeTrading/Trading Strategies/OffsetMA.mqh"
CStrategy *OffsetMAStrategy;
input group "Offset MA Strategy Settings";
input int MAPeriod_OffsetMA = 3;
input double OffsetPercentage_OffsetMA = 1;
input double ATRMultiplier_OffsetMA = 1;

// Create pointer to the selected strategy
CStrategy *activeStrategy;
CEdgeRiskScaling *edgeRiskScaling;
CPropFirmSimulation *propFirmSimulation;

int OnInit()
{
   // Set the static variable for all strategies
   CStrategy::SetServerHourDifference(ServerHourDifference);
   CStrategy::SetCompounding(UseCompounding);
   CStrategy::SetStartingBalance(StartingAccountBalance);
   
   if(RunSimulation)
   {
      edgeRiskScaling = new CEdgeRiskScaling();
      
      string strategyName = "";
      
      switch(StrategyChoice)
      {
         case 1: strategyName = "HourBreakout"; break;
         case 2: strategyName = "MiddleRange"; break;
         case 3: strategyName = "MARetest"; break;
         case 4: strategyName = "MACrossover"; break;
         case 5: strategyName = "OffsetMA"; break;
         default: strategyName = "InvalidStrategy"; break;
      }     
      propFirmSimulation = new CPropFirmSimulation(PhaseRun, StartingAccountBalance, strategyName);
   }

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
      
   // MA RETEST INITIALIZATION
   case 3:
      // Create MARetest object
      activeStrategy = new MARetest(MAPeriod_MARetest, Lookback_MARetest, ATRMultiplier_MARetest);
      if (activeStrategy != NULL)
      {
         activeStrategy.Init();
         Print("MARetest Strategy creation successfull.");
         return (INIT_SUCCEEDED);
      }
      break;
      
   // MA CROSSOVER INITIALIZATION
   case 4:
      // Create MARetest object
      activeStrategy = new MACrossover(ShortMAPeriod_MACRossover, LongMAPeriod_MACRossover, Lookback_MACRossover, ATRMultiplier_MACRossover);
      if (activeStrategy != NULL)
      {
         activeStrategy.Init();
         Print("MACrossover Strategy creation successfull.");
         return (INIT_SUCCEEDED);
      }
      break;
      
   // OFFSET MA INITIALIZATION
   case 5:
      // Create MARetest object
      activeStrategy = new OffsetMA(MAPeriod_OffsetMA, OffsetPercentage_OffsetMA, ATRMultiplier_OffsetMA);
      if (activeStrategy != NULL)
      {
         activeStrategy.Init();
         Print("Offset MA Strategy creation successfull.");
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
      delete propFirmSimulation;
      delete edgeRiskScaling;
      
      propFirmSimulation = NULL;
      edgeRiskScaling = NULL;
      activeStrategy = NULL;
   }
}

void OnTick()
{     
   //----------------------TRADING STRATEGIES----------------------       
   activeStrategy.ExecuteStrategy();
   
   
   
   //----------------------PROPFIRM SIMULATIONS----------------------
   if(RunSimulation)
      propFirmSimulation.UpdateChallengeStatus();
      
      
      
   //----------------------EDGE RISK SCALING----------------------
      
   if(RiskOverride > 0)
        activeStrategy.SetRisk(RiskOverride);
    else
        activeStrategy.SetRisk(edgeRiskScaling.GetRisk());
}

//Method to check if last closed trade was a win or loss
void OnTradeTransaction(const MqlTradeTransaction &trans, const MqlTradeRequest &request, const MqlTradeResult &result)
{
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD && RunSimulation)
   {
      ulong dealTicket = trans.deal;
      
      if(HistoryDealSelect(dealTicket))
      {
         double profit = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
         double commission = HistoryDealGetDouble(dealTicket, DEAL_COMMISSION);
         double swap = HistoryDealGetDouble(dealTicket, DEAL_SWAP);
         long reason = HistoryDealGetInteger(dealTicket, DEAL_REASON);
         double netProfit = NormalizeDouble(profit + commission + swap, 2);
         
         if(reason == DEAL_REASON_SL)
         {
            edgeRiskScaling.UpdateOutcome("Stop-Loss");
         }
         else if(reason == DEAL_REASON_TP)
         {
            edgeRiskScaling.UpdateOutcome("Take-Profit");
         }
      }
   }
}