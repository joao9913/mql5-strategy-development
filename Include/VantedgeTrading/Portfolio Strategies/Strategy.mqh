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
   //--------VARIABLES

protected:
   static int m_ServerHourDifference;
   static int m_activeHourStart;
   static int m_activeHourEnd;
   
   CTrade trade;  
   string m_objPrefix;
   double entryprice, stoploss, takeprofit, rr;

private:
   MqlRates priceData[];
   MqlDateTime currentTime;
   double m_riskPercentage;

   double currentBalance;
   datetime lastTime;
   //--------METHODS

protected:
   // Abstract method every strategy needs to implement
   virtual bool EntryCriteria() = 0;

   // Calculate lots depending on stoploss, entryprice, risk, balance, symbol
   double CalculateLots()
   {  
      double accountBalance = 10000;
         
      double slDistance = MathAbs(stoploss - entryprice);
      double pointSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT);            // Point size instead of tick size
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE); // Tick value
      double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      double lotSize = (m_riskPercentage / 100.0) * accountBalance / (slDistance * tickValue / pointSize);
      lotSize = MathMax(lotSize, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN));
      lotSize = MathMin(lotSize, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX));

      lotSize = MathFloor(lotSize / lotStep) * lotStep;

      return lotSize;
   }

   // Check if there are any open pending orders
   bool CheckOpenOrders()
   {
      if (OrdersTotal() == 0)
         return false;

      return true;
   }

   // Check if there are any open active trades
   bool CheckOpenTrades()
   {
      if (PositionsTotal() == 0)
         return false;

      return true;
   }
   
   //Check if current candle is new
   bool IsNewCandle()
   {
      datetime time = iTime(Symbol(), PERIOD_CURRENT, 0);
      
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

   // Cancel all open pending orders
   void CancelOpenOrders()
   {
      for (int k = OrdersTotal() - 1; k >= 0; k--)
      {
         ulong ticket = OrderGetTicket(k);
         trade.OrderDelete(ticket);
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
   virtual bool Init(){return true;}
   virtual void VisualMode() = 0;
   virtual bool CheckTimeframe(){return false;}
   
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
};

// Define + default value
int CStrategy::m_ServerHourDifference = 2;
int CStrategy::m_activeHourStart = 4;
int CStrategy::m_activeHourEnd = 20;