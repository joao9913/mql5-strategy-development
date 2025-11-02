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
      if (tradingAllowed /* and any other entry criterias*/)
      {
            return true;
      }
      return false;
   }

   // Enter market order on close direction
   void EnterTrade()
   {
      rr = 2.05;
      
      if(IsNewCandle())
      {
         Comment(TimeCurrent());
      }
      
      //tradingAllowed = false;
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