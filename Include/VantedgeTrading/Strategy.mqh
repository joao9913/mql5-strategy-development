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
   CTrade trade;
   // New NTrades
   bool tradingAllowed;

private:
   MqlRates priceData[];
   MqlDateTime currentTime;

   //--------METHODS

protected:
   // Abstract method every strategy needs to implement
   virtual bool EntryCriteria() = 0;

   // Common methods that any child "Strategy" will use the same way

   // Calculate lots depending on stoploss, entryprice, risk, balance, symbol
   double CalculateLots(double stoploss, double entryprice, double risk, double balance)
   {
      double slDistance = MathAbs(stoploss - entryprice);
      double pointSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT);            // Point size instead of tick size
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE); // Tick value
      double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      double lotSize = (risk / 100.0) * balance / (slDistance * tickValue / pointSize);
      lotSize = MathMax(lotSize, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN));
      lotSize = MathMin(lotSize, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX));

      lotSize = MathFloor(lotSize / lotStep) * lotStep;

      return lotSize;
   }

   // Check if there are any open pending orders
   bool CheckOpenPositions()
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

public:
   // Abstract method every strategy needs to implement
   virtual void ExecuteTrade() = 0;

   // Setter method to set the Server Hour Difference the same for every strategy
   static void SetServerHourDifference(int value)
   {
      m_ServerHourDifference = value;
   }

   // Reset control variables if no trades/orders are open
   void ResetControlVariables()
   {
      if (GetCurrentHour() == 20 + m_ServerHourDifference && GetCurrentMinute() <= 5)
      {
         if (!CheckOpenPositions() && !CheckOpenTrades())
         {
            tradingAllowed = true;
         }
      }
   }
};

// Define + default value
int CStrategy::m_ServerHourDifference = 2;