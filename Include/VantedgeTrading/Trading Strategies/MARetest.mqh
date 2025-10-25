//+------------------------------------------------------------------+
//|                                                     MARetest.mqh |
//|                                            VantedgeTrading, 2025 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "VantedgeTrading, 2025"
#property link "https://www.mql5.com"

#include "Strategy.mqh"

class MARetest : public CStrategy
{
   //--------VARIABLES
   
private:
   // Member input variables
   int m_maPeriod;
   int m_lookback;
   double m_atrMultiplier;
   
   //Strategy Variables
   int maDefinition;
   int atrDefinition;
   double maArray[];
   double atrArray[];
   
   datetime lastTime;  //Variable to store last candle time
   
   bool lookback; //Control if CheckLookback() needs to execute

   //--------METHODS

private:

   //Get MA Value
   double GetMAValue(int shift)
   {
      if(CopyBuffer(maDefinition, 0, shift, 1, maArray) > 0)
         return NormalizeDouble(maArray[0], _Digits);
      
      return 0;
   }
   
   //Get ATR Value
   double GetATRValue()
   {
      CopyBuffer(atrDefinition, 0, 0, 3, atrArray);
      return atrArray[0];
   }
   
   //Method to check if a new bar as formed
   bool IsNewBar()
   {
      datetime currentBarTime = iTime(_Symbol, _Period, 0);
      if(currentBarTime != lastTime)
      {
         lastTime = currentBarTime;
         return true;
      }
      return false;
   }
   
   //Method for checking wether price has stayed above/below the MA for "lookback" number of candles
   void CheckLookback()
   {
      if(IsNewBar() && !lookback)
      {
         double close = iClose(_Symbol, PERIOD_CURRENT, 1);
         double maValue = GetMAValue(1);
         
         if(close > maValue)
         {
            for(int i = 1; i <= m_lookback; i++)
            {
               double low = iLow(_Symbol, PERIOD_CURRENT, i);
               if(low < GetMAValue(i))
               {
                  lookback = false;
                  return;  
               }
            }
         }
         else if(close < maValue)
         {
            for(int i = 1; i <= m_lookback; i++)
            {
               double high = iHigh(_Symbol, PERIOD_CURRENT, i);
               if(high > GetMAValue(i))
               {
                  lookback = false;
                  return;  
               }
            }
         }
         lookback = true;
         return;
      }
   }
   
   //Method for checking if price is touching the MA
   string CheckRetest()
   {
      double close = iClose(Symbol(), PERIOD_CURRENT, 2);
      
      if(close > GetMAValue(2))
      {
         double low = iLow(_Symbol, PERIOD_CURRENT, 1);
         
         if(low < GetMAValue(1))
            return "Retest Long";
      }
      
      else if(close < GetMAValue(2))
      {
         double high = iHigh(_Symbol, PERIOD_CURRENT, 1);
         
         if(high > GetMAValue(1))
            return "Retest Short";
      }
      
      return "";
   }
   
   // Check if the entry criteria are met
   bool EntryCriteria() override
   {
      if(tradingAllowed && lookback)
      {
         if(CheckRetest() != "")
            return true;
      }
         
      return false;
   }
   
   void EnterTrade()
   {
      rr = 2.05;
      
      if(CheckRetest() == "Retest Long")
      {
         entryprice = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
         stoploss = entryprice - GetATRValue() * m_atrMultiplier;
         takeprofit = entryprice + (entryprice - stoploss) * 2;
         trade.Buy(CalculateLots(), Symbol(), entryprice, stoploss, takeprofit);
         tradingAllowed = false;
      }
      
      else if(CheckRetest() == "Retest Short")
      {  
         entryprice = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
         stoploss = entryprice + GetATRValue() * m_atrMultiplier;
         takeprofit = entryprice - (stoploss - entryprice) * 2;
         trade.Sell(CalculateLots(), Symbol(), entryprice, stoploss, takeprofit);
         tradingAllowed = false;
      }
   }

public:
   // Constructor for input variables
   MARetest(int maPeriod, int lookbackBars, int atrMultiplier)
   {
      m_maPeriod = maPeriod;
      m_lookback = lookbackBars;
      m_atrMultiplier = atrMultiplier;  
   }
   
   //Similar to OnInit
   bool Init() override
   {
      maDefinition = iMA(Symbol(), PERIOD_CURRENT, m_maPeriod, 0, MODE_SMA, PRICE_CLOSE);
      atrDefinition = iATR(Symbol(), PERIOD_CURRENT, m_maPeriod);
      
      if(maDefinition == INVALID_HANDLE || atrDefinition == INVALID_HANDLE)
         return false;
         
      ArraySetAsSeries(maArray, true);
      ArraySetAsSeries(atrArray, true);
            
      return true;
   }

   // Execute trades if all conditions are met
   void ExecuteStrategy() override
   {
      CheckLookback();
      
      if(EntryCriteria())
         EnterTrade();

      ResetControlVariables();
   }
};