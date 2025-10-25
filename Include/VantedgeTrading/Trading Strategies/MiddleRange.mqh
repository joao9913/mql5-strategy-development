//+------------------------------------------------------------------+
//|                                                  MiddleRange.mqh |
//|                                            VantedgeTrading, 2025 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "VantedgeTrading, 2025"
#property link "https://www.mql5.com"

#include "Strategy.mqh"

class MiddleRange : public CStrategy
{
   //--------VARIABLES

private:
   // Member input variables
   int m_rangeBars;
   int m_entryHour;
   int m_entryMinute;

   // Range variables to use when entering orders
   double rangeHigh;
   double rangeLow;
   double rangeMiddle;

   //--------METHODS

private:
   // Check if hour is within entry hour range
   bool CheckEntryHour()
   {
      if (GetCurrentHour() == m_entryHour + m_ServerHourDifference && GetCurrentMinute() == m_entryMinute)
         return true;

      return false;
   }

   // Calculate range
   void CalculateRange()
   {
      double high = iHigh(Symbol(), PERIOD_CURRENT, 1);
      double low = iLow(Symbol(), PERIOD_CURRENT, 1);

      rangeHigh = high;
      rangeLow = low;

      for (int i = 1; i < m_rangeBars; i++)
      {
         low = iLow(Symbol(), 0, i);
         high = iHigh(Symbol(), 0, i);

         if (low < rangeLow)
            rangeLow = low;

         if (high > rangeHigh)
            rangeHigh = high;
      }

      rangeMiddle = NormalizeDouble(rangeHigh - (rangeHigh - rangeLow) / 2, _Digits);
   }

   // Check if price closed above or below the middle of the range
   string CheckCloseMiddleRange()
   {
      double close = iClose(Symbol(), PERIOD_M30, 1);

      if (close > rangeMiddle)
         return "Close Above Middle";

      else if (close < rangeMiddle)
         return "Close Below Middle";

      return NULL;
   }

   // Check if the entry criteria are met
   bool EntryCriteria() override
   {
      if (CheckEntryHour() && tradingAllowed)
      {
         CalculateRange();
         if (CheckCloseMiddleRange() != NULL)
            return true;
      }

      return false;
   }

   // Enter market order on close direction
   void EnterTrade()
   {
      rr = 2.05;

      // Place long market order
      if (CheckCloseMiddleRange() == "Close Above Middle")
      {
         entryprice = iClose(Symbol(), PERIOD_M30, 1);
         stoploss = rangeLow;
         takeprofit = NormalizeDouble(entryprice + (entryprice - stoploss) * 2.05, _Digits);
         trade.Buy(CalculateLots(), Symbol(), entryprice, stoploss, takeprofit);

         tradingAllowed = false;
      }
      // Place short market order
      else if (CheckCloseMiddleRange() == "Close Below Middle")
      {
         entryprice = iClose(Symbol(), PERIOD_M30, 1);
         stoploss = rangeHigh;
         takeprofit = NormalizeDouble(entryprice - (stoploss - entryprice) * 2.05, _Digits);
         trade.Sell(CalculateLots(), Symbol(), entryprice, stoploss, takeprofit);

         tradingAllowed = false;
      }
   }

public:
   // Constructor for input variables
   MiddleRange(int rangeBars, int entryHour, int entryMinute)
   {
      if (Symbol() == "USDJPY")
      {
         m_rangeBars = 3;
         m_entryHour = 4;
         m_entryMinute = 30;
         return;
      }
      else
      {
         m_rangeBars = rangeBars;
         m_entryHour = entryHour;
         m_entryMinute = entryMinute;
      }
   }

   // Execute trades if all conditions are met
   void ExecuteStrategy() override
   {
      if (EntryCriteria())
         EnterTrade();

      ResetControlVariables();
   }
};