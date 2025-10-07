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
   bool m_lastTradeOutcome;

   // New NTrades
   bool tradingAllowed;

private:
   MqlRates priceData[];
   MqlDateTime currentTime;
   double m_riskPercentage;
   datetime lastTime;

   //--------METHODS

protected:
   // Abstract method every strategy needs to implement
   virtual bool EntryCriteria() = 0;

   // Calculate lots depending on stoploss, entryprice, risk, balance, symbol
   double CalculateLots(double stoploss, double entryprice, double balance)
   {
      double slDistance = MathAbs(stoploss - entryprice);
      double pointSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT);            // Point size instead of tick size
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE); // Tick value
      double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      double lotSize = (m_riskPercentage / 100.0) * balance / (slDistance * tickValue / pointSize);
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

   // Cancel all open pending orders
   void CancelOpenOrders()
   {
      for (int k = OrdersTotal() - 1; k >= 0; k--)
      {
         ulong ticket = OrderGetTicket(k);
         trade.OrderDelete(ticket);
      }
   }
   
   //Check if new candle is formed
   bool IsNewCandle()
   {
      datetime actualTime= iTime(Symbol(), PERIOD_CURRENT, 0);
      if(actualTime != lastTime)
      {
         lastTime = actualTime;
         return true;
      }
      return false;
   }

public:
   // Abstract method every strategy needs to implement
   virtual void ExecuteStrategy() = 0;

   // Setter method to set the Server Hour Difference the same for every strategy
   static void SetServerHourDifference(int value)
   {
      m_ServerHourDifference = value;
   }

   void SetRisk(double riskPercentage)
   {
      m_riskPercentage = riskPercentage;
   }

   void setLastTradeOutcome(bool outcome)
   {
      // true = win / false = loss
      m_lastTradeOutcome = outcome;
   }

   bool getLastTradeOutcome()
   {
      return m_lastTradeOutcome;
   }

   // Call this method after a trade closes
   void UpdateTradeOutcome(bool tradeOutcome)
   {
      m_lastTradeOutcome = tradeOutcome;
   }
};

// Define + default value
int CStrategy::m_ServerHourDifference = 2;