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

   void VisualMode() override
   {
      string prefix = m_objPrefix + "_MIDDLERANGE";
      
      if(CheckEntryHour())
      {
         //Draw Range
         datetime timeStart = iTime(_Symbol, PERIOD_H1, m_rangeBars);
         datetime timeEnd = iTime(_Symbol, PERIOD_H1, 0);
         
         ObjectCreate(0, prefix + "Range", OBJ_RECTANGLE, 0, timeStart, rangeHigh, timeEnd, rangeLow);
         ObjectSetInteger(0, prefix + "Range", OBJPROP_COLOR, clrMediumSpringGreen);
         ObjectSetInteger(0, prefix + "Range", OBJPROP_BACK, true);
         
         //Draw Entry Lines
         ObjectCreate(0, prefix + "EntryHour", OBJ_VLINE, 0, timeStart, rangeHigh);
         ObjectSetInteger(0, prefix+"EntryHour", OBJPROP_COLOR, clrMaroon);
         
         //Draw Middle Line
         ObjectCreate(0, prefix + "Middle", OBJ_TREND, 0, timeStart, rangeMiddle, timeEnd, rangeMiddle);
         ObjectSetInteger(0, prefix+"Middle", OBJPROP_COLOR, clrMediumSpringGreen);
         
         ChartRedraw(0); 
      }
      
      ChartRedraw(0); 
   }
   
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
      double high = iHigh(_Symbol, PERIOD_H1, 1);
      double low = iLow(_Symbol, PERIOD_H1, 1);

      rangeHigh = high;
      rangeLow = low;

      for (int i = 1; i < m_rangeBars; i++)
      {
         low = iLow(_Symbol, 0, i);
         high = iHigh(_Symbol, 0, i);

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
      double close = iClose(_Symbol, PERIOD_M30, 1);

      if (close > rangeMiddle)
         return "Close Above Middle";

      else if (close < rangeMiddle)
         return "Close Below Middle";

      return NULL;
   }

   // Check if the entry criteria are met
   bool EntryCriteria() override
   {
      if (CheckEntryHour() && tradingAllowed && CheckActiveTimeRange())
      {
         CalculateRange();
         ClearVisualMode();
         VisualMode();
         
         if (CheckCloseMiddleRange() != NULL)
            return true;
      }

      return false;
   }

   // Enter market order on close direction
   void EnterTrade()
   {
      // Place long market order
      if (CheckCloseMiddleRange() == "Close Above Middle")
      {
         entryprice = iClose(_Symbol, PERIOD_M30, 1);
         stoploss = rangeLow;
         takeprofit = NormalizeDouble(entryprice + (entryprice - stoploss) * 2.05, _Digits);
         trade.Buy(CalculateLots(), _Symbol, entryprice, stoploss, takeprofit);

         tradingAllowed = false;
      }
      // Place short market order
      else if (CheckCloseMiddleRange() == "Close Below Middle")
      {
         entryprice = iClose(_Symbol, PERIOD_M30, 1);
         stoploss = rangeHigh;
         takeprofit = NormalizeDouble(entryprice - (stoploss - entryprice) * 2.05, _Digits);
         trade.Sell(CalculateLots(), _Symbol, entryprice, stoploss, takeprofit);

         tradingAllowed = false;
      }
   }

public:
   // Constructor for input variables
   MiddleRange()
   {
      if (_Symbol == "USDJPY")
      {
         m_rangeBars = 3;
         m_entryHour = 4;
         m_entryMinute = 30;
         SetMagic(120101);
         return;
      }
      
      m_rangeBars = 0;
      m_entryHour = 0;
      m_entryMinute = 0;
      SetMagic(0);
   }

   // Execute trades if all conditions are met
   void ExecuteStrategy() override
   {
      if (EntryCriteria())
      {
         EnterTrade();
      }

      ResetControlVariables();
   }
};