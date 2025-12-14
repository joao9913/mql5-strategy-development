//+------------------------------------------------------------------+
//|                                                     Strategy.mqh |
//|                                            VantedgeTrading, 2025 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "VantedgeTrading, 2025"
#property link "https://www.mql5.com"

#include <Trade/Trade.mqh>

class CStrategy
{
protected:
   static int m_ServerHourDifference;
   static int m_activeHourStart;
   static int m_activeHourEnd;
   
   CTrade trade;  
   string m_objPrefix;
   bool tradingAllowed;
   double entryprice, stoploss, takeprofit;

private:
   MqlRates priceData[];
   MqlDateTime currentTime;
   double m_riskPercentage;
   long m_magic;
   double currentBalance;
   datetime lastTime;

protected:
   virtual bool EntryCriteria() = 0;

   double CalculateLots()
   {  
      double accountBalance = 10000;
      //double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      
      double slDistance = MathAbs(stoploss - entryprice);
      double pointSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      double lotSize = (m_riskPercentage / 100.0) * accountBalance / (slDistance * tickValue / pointSize);
      lotSize = MathMax(lotSize, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN));
      lotSize = MathMin(lotSize, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX));
      lotSize = MathFloor(lotSize / lotStep) * lotStep;
      return lotSize;
   }
   
   datetime GetTradingDay(datetime t)
   {
      return (datetime)(t - (t % 86400));
   }
   
   bool TradedTodayFromHistory()
   {
      datetime todayStart = GetTradingDay(TimeCurrent());
      datetime now        = TimeCurrent();
   
      if(!HistorySelect(todayStart, now))
         return false;
   
      int deals = HistoryDealsTotal();
      if(deals == 0)
         return false;
   
      for(int i = deals - 1; i >= 0; i--)
      {
         ulong dealTicket = HistoryDealGetTicket(i);
         if(dealTicket == 0)
            continue;
   
         // Only ENTRY deals
         if((ENUM_DEAL_ENTRY)HistoryDealGetInteger(dealTicket, DEAL_ENTRY) 
            != DEAL_ENTRY_IN)
            continue;
   
         // Only this strategy
         if(HistoryDealGetInteger(dealTicket, DEAL_MAGIC) != m_magic)
            continue;
   
         // Only this symbol
         if(HistoryDealGetString(dealTicket, DEAL_SYMBOL) != _Symbol)
            continue;
   
         // Found an entry today
         return true;
      }
   
      return false;
   } 

   // Check if there are any open pending orders
   bool CheckOpenOrders()
   {      
      for (int k = OrdersTotal() - 1; k >= 0; k--)
      {
         ulong ticket = OrderGetTicket(k);
         if(OrderGetString(ORDER_SYMBOL) == _Symbol)
           return true;
      }
      
      return false;
   }
   
   // Cancel all open pending orders
   void CancelOpenOrders()
   {
      for (int k = OrdersTotal() - 1; k >= 0; k--)
      {
         ulong ticket = OrderGetTicket(k);
         if(OrderGetString(ORDER_SYMBOL) == _Symbol)
            trade.OrderDelete(ticket);
      }
   }

   // Check if there are any open active trades
   bool CheckOpenTrades()
   {      
      for (int k = PositionsTotal() - 1; k >= 0; k--)
      {
         ulong ticket = PositionGetTicket(k);
         if(PositionGetString(POSITION_SYMBOL) == _Symbol)
           return true;
      }
      
      return false;
   }
   
   //Check if current candle is new
   bool IsNewCandle()
   {
      datetime time = iTime(_Symbol, PERIOD_CURRENT, 0);
      
      if(time != lastTime)
      {
         lastTime = time;
         return true;
      }
      return false;
   }

   // Get current hour from currentTime()
   int GetCurrentHour()
   {
      TimeCurrent(currentTime);
      return currentTime.hour;
   }

   // Get current minute from currentTime()
   int GetCurrentMinute()
   {
      TimeCurrent(currentTime);
      return currentTime.min;
   }
   
   //Check if time is within active hour range
   bool CheckActiveTimeRange()
   {
      int hour = GetCurrentHour() - m_ServerHourDifference;
      
      if(hour >= m_activeHourStart && hour < m_activeHourEnd)
         return true;
         
      return false;
   }

   // Reset control variables if no trades/orders are open
   void ResetControlVariables()
   {
      if (GetCurrentHour() == 20 + m_ServerHourDifference && GetCurrentMinute() <= 5)
      {
         if (!CheckOpenOrders() && !CheckOpenTrades())
         {
            tradingAllowed = true;
         }
      }
   }

   //Remove old objects from visual mode
   virtual void ClearVisualMode()
   {
      ObjectsDeleteAll(0, m_objPrefix);
   }

public:
   // Abstract method every strategy needs to implement
   virtual void ExecuteStrategy() = 0;
   virtual bool Init()
   {
      //Default: allow trading
      tradingAllowed = true;
      
      //If this strategy already traded today, block it
      if(TradedTodayFromHistory())
      {
         tradingAllowed = false;
         Print("Already traded today: ", _Symbol, m_magic);
      }
      
      return true;
   }
   virtual void VisualMode() = 0;
   virtual ENUM_TIMEFRAMES RequiredTimeframe() = 0;
   
   CStrategy()
   {
      m_objPrefix = __FUNCTION__;
   }

   // Setter method to set the Server Hour Difference the same for every strategy
   static void SetServerHourDifference(int value)
   {
      m_ServerHourDifference = value;
   }

   void SetRisk(double riskPercentage)
   {
      m_riskPercentage = riskPercentage;
   }
   
   void SetMagic(long magic)
   {
      m_magic = magic;
   }
   
   bool IsCorrectTimeframe()
   {
      return _Period == RequiredTimeframe();
   }
};

// Define + default value
int CStrategy::m_ServerHourDifference = 2;
int CStrategy::m_activeHourStart = 4;
int CStrategy::m_activeHourEnd = 20;