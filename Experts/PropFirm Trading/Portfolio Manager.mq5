//+------------------------------------------------------------------+
//|                                                      Experts.mq5 |
//|                                            VantedgeTrading, 2025 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "VantedgeTrading, 2025"
#property link "https://www.mql5.com"
#property version "1.00"

#include "../../Include/VantedgeTrading/PropFirm Tracker/Portfolio Strategies/Strategy.mqh";
#include "../../Include/VantedgeTrading/PropFirm Tracker/PropFirm Tracker.mqh";

//------------ GLOBAL INPUTS ------------
input group "Account Settings";
enum accountPhase
{
   MODE_CHALLENGE=1,
   MODE_VERIFICATION=2,
   MODE_FUNDED=3,
   MODE_MANUAL=4,
}; 
input accountPhase AccountPhase = MODE_CHALLENGE;
enum strategyChoice
{
   HourBreakout_Strategy = 1,
   MiddleRange_Strategy  = 2,
   MACrossover_Strategy  = 3
};
input strategyChoice StrategyChoice = HourBreakout_Strategy;

input int AccountBalance = 10000;
input int ServerHourDifference = 2;
input double RiskOverride = 0.0;
input int RiskDivisionOverride = 0;

#include "../../Include/VantedgeTrading/PropFirm Tracker/Portfolio Strategies/HourBreakout.mqh";
CStrategy *HourBreakoutStrategy;
#include "../../Include/VantedgeTrading/PropFirm Tracker/Portfolio Strategies/MiddleRange.mqh";
CStrategy *MiddleRangeStrategy;
#include "../../Include/VantedgeTrading/PropFirm Tracker/Portfolio Strategies/MACrossover.mqh";
CStrategy *MACrossoverStrategy;

// Create pointer to the selected strategy
CStrategy *activeStrategy;
CPropFirmTracker *propFirmTracker;

int OnInit()
{
   // Set the static variable for all strategies
   CStrategy::SetServerHourDifference(ServerHourDifference);
   int numberOfStrategies = 0;

   switch (StrategyChoice)
   {
      case 1:
         activeStrategy = new HourBreakout();
         numberOfStrategies = 3;
         break;
         
      case 2:
         activeStrategy = new MiddleRange();
         numberOfStrategies = 3;
         break;
         
      case 3:
         activeStrategy = new MACrossover();
         numberOfStrategies = 2;
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
   
   activeStrategy.SetStartingBalance(AccountBalance);
   
   if(RiskDivisionOverride != 0)
      numberOfStrategies = RiskDivisionOverride;
   
   if(RiskOverride != 0)
      numberOfStrategies = 1;
   
   propFirmTracker = new CPropFirmTracker(AccountPhase, AccountBalance, RiskOverride, numberOfStrategies);
   activeStrategy.SetRisk(propFirmTracker.GetRisk());
   
   int account = 666;
   string symbol = "EURUSD";
   double pnl = 50.25;
   datetime open_time = TimeCurrent();
   datetime close_time = TimeCurrent();
   long ticket_id = 123456;
   double balance = 10500.00;
   
   propFirmTracker.updateTrackerApp(account, symbol, pnl, open_time, close_time, ticket_id, balance);
      
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   if (activeStrategy != NULL)
   {
      delete activeStrategy;
      delete propFirmTracker;
      propFirmTracker = NULL;
      activeStrategy = NULL;
   }
}

void OnTick()
{     
   if(propFirmTracker.RunTracking())
      activeStrategy.ExecuteStrategy();
}

//Send information to Account_Tracker web app on trade close
void OnTradeTransaction(const MqlTradeTransaction &trans, const MqlTradeRequest &request, const MqlTradeResult &result)
{
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
   {
      ulong dealTicket = trans.deal;
      
      if(HistoryDealSelect(dealTicket))
      {
         long reason = HistoryDealGetInteger(dealTicket, DEAL_REASON);
         
         if(reason == DEAL_ENTRY_OUT)
         {
            string symbol = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
            datetime close_datetime = HistoryDealGetInteger(dealTicket, DEAL_TIME);
            double pnl = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
            double balance = AccountInfoDouble(ACCOUNT_BALANCE);
            int strategyID = StrategyChoice;
            
            ulong orderTicket = HistoryDealGetInteger(dealTicket, DEAL_ORDER);
            datetime open_datetime = 0;
            if(HistoryOrderSelect(orderTicket))
               open_datetime = HistoryOrderGetInteger(orderTicket, ORDER_TIME_SETUP);
            
            
            propFirmTracker.updateTrackerApp(symbol, open_datetime, close_datetime, dealTicket, pnl, strategyID, balance);
         }
      }
   }
}