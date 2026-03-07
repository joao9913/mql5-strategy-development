//+------------------------------------------------------------------+
//|                                                 HourBreakout.mqh |
//|                                            VantedgeTrading, 2025 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "VantedgeTrading, 2025"
#property link "https://www.mql5.com"

#include "Strategy.mqh"

class DynamicRangeBreakout : public CStrategy
{
   //--------VARIABLES

private:
   // Member input variables
   int m_rangeBars;
   int m_atrPeriod;
   double m_atrMultiplier;

   // Range variables to use when entering orders
   double rangeHigh;
   double rangeLow;
   double rangeSize;
   int atrDefinition;
   double priceArray[];
   
   //--------METHODS

private:
  
   void VisualMode() override
   {
      if(!m_visualMode) return;
      
      string prefix = m_objPrefix + "_DYNAMICRANGEBREAKOUT";
      
      //Draw Range
      datetime timeStart = iTime(_Symbol, PERIOD_H1, m_rangeBars);
      datetime timeEnd = iTime(_Symbol, PERIOD_H1, 0);
      
      ObjectCreate(0, prefix + "Range", OBJ_RECTANGLE, 0, timeStart, rangeHigh, timeEnd, rangeLow);
      ObjectSetInteger(0, prefix + "Range", OBJPROP_COLOR, clrMediumSpringGreen);
      ObjectSetInteger(0, prefix + "Range", OBJPROP_BACK, true);
      
      ChartRedraw(0); 
   }
   
   //Get ATR Value
   double GetATRValue()
   {
      CopyBuffer(atrDefinition, 0, 0, 3, priceArray);
      return NormalizeDouble(priceArray[0], _Digits) * 100;
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
      
      rangeSize = (rangeHigh - rangeLow) * 100;
   }
   
   bool CheckRangeSize()
   {
      if(rangeSize < GetATRValue() * m_atrMultiplier)
         return true;
       
      return false;
   }
   
   void CheckBreakout()
   {
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      rr = 2.05;
      
      if(ask > rangeHigh)
      {
         entryprice = ask;
         stoploss = rangeLow;
         takeprofit = NormalizeDouble(entryprice + (entryprice - stoploss) * rr, _Digits);
         trade.Buy(CalculateLots(), _Symbol, entryprice, stoploss, takeprofit);
         tradingAllowed = false;
      }
      
      if(bid < rangeLow)
      {
         entryprice = bid;
         stoploss = rangeHigh;
         takeprofit = NormalizeDouble(entryprice - (stoploss - entryprice) * rr, _Digits);
         trade.Sell(CalculateLots(), _Symbol, entryprice, stoploss, takeprofit);
         tradingAllowed = false;
      }
   }

   // Check if the entry criteria are met
   bool EntryCriteria() override
   {      
      if(tradingAllowed && CheckActiveTimeRange())
      {
         CalculateRange();
         
         if(m_visualMode)
         {
            ClearVisualMode();
            VisualMode();
         }
         
         if(CheckRangeSize())
            return true;
      }

      return false;
   }

public:
   // Constructor for input variables
   DynamicRangeBreakout(int rangeBars, int atrPeriod, double atrMultiplier)
   {
      /*if (_Symbol == "USDJPY")
      {
         m_rangeBars = 3;
         m_entryHour = 3;
         return;
      }*/

      m_rangeBars = rangeBars;
      m_atrPeriod = atrPeriod;
      m_atrMultiplier = atrMultiplier;
   }

   // Execute trades if all conditions are met
   void ExecuteStrategy() override
   {
      if(EntryCriteria())
      {  
         DebuggingMode();
         CheckBreakout();  
      }
      
      ResetControlVariables();
   }
   
   bool Init()
   {
      atrDefinition = iATR(Symbol(),PERIOD_CURRENT, m_atrPeriod);
      if(atrDefinition == INVALID_HANDLE)
         return false;
         
      ArraySetAsSeries(priceArray, true);
      
      return true;
   }
};