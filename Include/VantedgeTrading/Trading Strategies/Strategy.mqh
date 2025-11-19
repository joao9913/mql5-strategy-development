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
   static int m_startingBalance;
   static bool m_setCompounding;
   static bool m_visualMode;
   static bool m_debuggingMode;
   
   CTrade trade;  
   string m_objPrefix;
   bool tradingAllowed;
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
      double accountBalance = m_startingBalance;
      
      if(m_setCompounding)
         accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
         
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
   
   //Debugging mode - TesterStop right after entering a trade
   void DebuggingMode()
   {  
      if(m_debuggingMode)
      {
         if(CheckOpenTrades() || CheckOpenOrders())
            TesterStop();
      }
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
   
   CStrategy()
   {
      m_visualMode = true;
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
   
   static void SetStartingBalance(int startingBalance)
   {
      m_startingBalance = startingBalance;
   }
   
   static void SetCompounding(bool compounding)
   {
      m_setCompounding = compounding;
   }
   
   static void SetVisualMode(bool visualMode)
   {
      m_visualMode = visualMode;
   }
   
   static void SetDebuggingMode(bool debuggingMode)
   {
      m_debuggingMode = debuggingMode;
   }
};

// Define + default value
int CStrategy::m_ServerHourDifference = 2;
int CStrategy::m_startingBalance = 10000;
bool CStrategy::m_setCompounding = false;
bool CStrategy::m_visualMode = false;
bool CStrategy::m_debuggingMode = false;