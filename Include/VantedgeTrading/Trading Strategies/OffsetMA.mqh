//+------------------------------------------------------------------+
//|                                                     OffsetMA.mqh |
//|                                            VantedgeTrading, 2025 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "VantedgeTrading, 2025"
#property link "https://www.mql5.com"

#include "Strategy.mqh"

class OffsetMA : public CStrategy
{
   //--------VARIABLES

private:
   
   // Member input variables
   int m_maPeriod;
   double m_offsetPercentage;
   double m_atrMultiplier;
   
   //Strategy variables
   int maDefinition;
   int atrDefinition;
   double maArray[];
   double atrArray[];
   
   //--------METHODS

private:
   
   // Check if the entry criteria are met
   bool EntryCriteria() override
   {
      if (tradingAllowed && IsNewCandle())
      {
         if(OffsetRetest() != "")
            return true;
      }
      return false;
   }

   // Enter market order on close direction
   void EnterTrade()
   {
      rr = 2.05;
      string direction = OffsetRetest();
      double atrValue = GetATRValue();
      
      if(direction == "Long")
      {
         entryprice = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
         stoploss = entryprice - atrValue * m_atrMultiplier;
         takeprofit = NormalizeDouble(entryprice + (entryprice - stoploss) * rr, _Digits);
         trade.Buy(CalculateLots(), Symbol(), entryprice, stoploss, takeprofit);

         tradingAllowed = false;
      }
      else if(direction == "Short")
      {
         entryprice = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
         stoploss = entryprice + atrValue * m_atrMultiplier;
         takeprofit = NormalizeDouble(entryprice - (stoploss - entryprice) * rr, _Digits);
         trade.Sell(CalculateLots(), Symbol(), entryprice, stoploss, takeprofit);

         tradingAllowed = false;
      }
   }
   
   void VisualMode() override
   {
      if(!m_visualMode) return;
      
      string prefix = m_objPrefix + "_OFFSETMA";
      
      
      ChartRedraw(0); 
   }
   
   //Check if price touches an offset
   string OffsetRetest()
   {
      double positiveOffset = PositiveOffset();
      double negativeOffset = NegativeOffset();
      double currentLow = iLow(_Symbol, PERIOD_CURRENT, 0);
      double currentHigh = iHigh(_Symbol, PERIOD_CURRENT, 0);
      
      if(currentLow <= negativeOffset)
      {
         return "Long";
      }
      else if(currentHigh >= positiveOffset)
      {
         return "Short";
      }
      else
         return "";
   }
   
   //Calculate positive offset
   double PositiveOffset()
   {
      double offset;
      double maValue = GetMAValue();
      
      offset = maValue + maValue * m_offsetPercentage;
      
      return offset;
   }
   
   //Calculate negative offset
   double NegativeOffset()
   {
      double offset;
      double maValue = GetMAValue();
      
      offset = maValue - maValue * m_offsetPercentage;
      
      return offset;
   }
   
   //Get MA Value
   double GetMAValue()
   {
      CopyBuffer(maDefinition, 0, 0, 1, maArray);
      return NormalizeDouble(maArray[0], _Digits);
   }
   
   //Get ATR Value
   double GetATRValue()
   {
      CopyBuffer(atrDefinition, 0, 0, 3, atrArray);
      return NormalizeDouble(atrArray[0], _Digits);
   }

public:
   // Constructor for input variables
   OffsetMA(int maPeriod, double offsetPercentage, double atrMultiplier)
   { 
      m_maPeriod = maPeriod;
      m_offsetPercentage = offsetPercentage / 1000;
      m_atrMultiplier = atrMultiplier;
   }

   // Execute trades if all conditions are met
   void ExecuteStrategy() override
   {
      if (EntryCriteria())
         EnterTrade();

      ResetControlVariables();
   }
   
   bool Init()
   {
      maDefinition = iMA(Symbol(), PERIOD_CURRENT, m_maPeriod, 0, MODE_SMA, PRICE_CLOSE);
      if(maDefinition == INVALID_HANDLE)
         return false;
         
      atrDefinition = iATR(Symbol(),PERIOD_CURRENT, m_maPeriod);
      if(atrDefinition == INVALID_HANDLE)
         return false;
         
      ArraySetAsSeries(maArray, true);
      ArraySetAsSeries(atrArray, true);
      
      return true;
   }
};