//+------------------------------------------------------------------+
//|                                                 MA Crossover.mqh |
//|                                            VantedgeTrading, 2025 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "VantedgeTrading, 2025"
#property link "https://www.mql5.com"

#include "Strategy.mqh"

class MACrossover : public CStrategy
{
   //--------VARIABLES

private:
   // Member input variables
   int m_shortMAPeriod;
   int m_longMAPeriod;
   int m_lookbackBars;
   double m_atrMultiplier;
   
   //Strategy Variables
   int shortMADefinition;
   int longMADefinition;
   int atrDefinition;
   double shortMAArray[];
   double longMAArray[];
   double priceArray[];
   bool lookback;

private:
    
   //Get Short MA Value
   double GetShortMAValue(int shift)
   {
      CopyBuffer(shortMADefinition, 0, shift, 1, shortMAArray);
      return NormalizeDouble(shortMAArray[0], _Digits);
   }
   
   //Get Long MA Value
   double GetLongMAValue(int shift)
   {
      CopyBuffer(longMADefinition, 0, shift, 1, longMAArray);
      return NormalizeDouble(longMAArray[0], _Digits);
   }
   
   //Get ATR Value
   double GetATRValue()
   {
      CopyBuffer(atrDefinition, 0, 0, 3, priceArray);
      return NormalizeDouble(priceArray[0], _Digits);
   }
   
   void VisualMode() override
   {
      string prefix = m_objPrefix + "_MACROSSOVER";
      ChartRedraw(0); 
   }
     
   //Check if ShortMA was away from LongMA for lookback candles
   void CheckMALookback()
   {      
      if(!lookback)
      {
         double currentLongMAValue = GetLongMAValue(1);
         double currentShortMAValue = GetShortMAValue(1);
         
         if(currentShortMAValue > currentLongMAValue)
         {
            for(int i = 2; i <= m_lookbackBars; i++)
            {
               double pastLongMAValue = GetLongMAValue(i);
               double pastShortMAValue = GetShortMAValue(i);
               
               if(pastShortMAValue <= pastLongMAValue)
               {
                  lookback = false;
                  return;
               }
            }
         }
         else if(currentShortMAValue < currentLongMAValue)
         {
            for(int i = 2; i <= m_lookbackBars; i++)
            {
               double pastLongMAValue = GetLongMAValue(i);
               double pastShortMAValue = GetShortMAValue(i);
               
               if(pastShortMAValue >= pastLongMAValue)
               {
                  lookback = false;
                  return;
               }
            }
         }
         else
         {
            lookback = false;
            return;
         }
         
         lookback = true;
      }
   }
   
   //If CheckMALookback is true, checks if there is a crossover of the two MAs
   string CheckMACrossover()
   {
      if(lookback)
      {
         double previousLongMAValue = GetLongMAValue(1);
         double previousShortMAValue = GetShortMAValue(1);
         double currentLongMAValue = GetLongMAValue(0);
         double currentShortMAValue = GetShortMAValue(0);
         
         if(previousShortMAValue > previousLongMAValue)
         {
            if(currentShortMAValue <= previousLongMAValue)
               return "Short";
         }
         else if(previousShortMAValue < previousLongMAValue)
         {
            if(currentShortMAValue >= previousLongMAValue)
               return "Long";
         }
      }
      
      return "";
   }

   // Check if the entry criteria are met
   bool EntryCriteria() override
   {
      if(IsNewCandle() && tradingAllowed && CheckActiveTimeRange() && m_shortMAPeriod < m_longMAPeriod) 
      {
         CheckMALookback();
         
         if(CheckMACrossover() != "")
            return true;
      }
      
      return false;
   }

   // Enter market order on close direction
   void EnterTrade(string direction)
   {
      if(direction == "Long")
      {
         entryprice = SymbolInfoDouble(_Symbol, SYMBOL_ASK); 
         stoploss = entryprice - GetATRValue() * m_atrMultiplier;
         takeprofit = entryprice + (entryprice - stoploss) * 2.05;
         trade.Buy(CalculateLots(), _Symbol, entryprice, stoploss, takeprofit);  
         
         tradingAllowed = false;
         lookback = false;
      }
      else if(direction == "Short")
      {
         entryprice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);   
         stoploss = entryprice + GetATRValue() * m_atrMultiplier;
         takeprofit = entryprice - (stoploss - entryprice) * 2.05;
         trade.Sell(CalculateLots(), _Symbol, entryprice, stoploss, takeprofit);
         
         tradingAllowed = false;
         lookback = false;
      }
   }

public:
   // Constructor for input variables
   MACrossover()
   {
      if (_Symbol == "GBPUSD")
      {
         m_shortMAPeriod = 30;
         m_longMAPeriod = 175;
         m_lookbackBars = 55;
         m_atrMultiplier = 4;
         SetMagic(1301001);
         m_period = PERIOD_M15;         
         return;
      }
      else if (_Symbol == "USDJPY")
      {
         m_shortMAPeriod = 15;
         m_longMAPeriod = 120;
         m_lookbackBars = 5;
         m_atrMultiplier = 5;
         SetMagic(1301002);
         m_period = PERIOD_M15; 
         return;
      }
      else if (_Symbol == "XAUUSD")
      {
         m_shortMAPeriod = 90;
         m_longMAPeriod = 130;
         m_lookbackBars = 10;
         m_atrMultiplier = 4;
         SetMagic(1301003);
         m_period = PERIOD_M15; 
         return;
      }
      
      m_shortMAPeriod = 0;
      m_longMAPeriod = 0;
      m_lookbackBars = 0;
      m_atrMultiplier = 0;
      SetMagic(0);
      m_period = PERIOD_D1; 
      return;
   }
   
   //--- Initialization method (similar to OnInit)
   bool Init()
   {
      shortMADefinition = iMA(_Symbol, PERIOD_M15, m_shortMAPeriod, 0, MODE_SMA, PRICE_CLOSE);
      if(shortMADefinition == INVALID_HANDLE)
         return false;
      
      longMADefinition = iMA(_Symbol, PERIOD_M15, m_longMAPeriod, 0, MODE_SMA, PRICE_CLOSE);
      if(longMADefinition == INVALID_HANDLE)
         return false;
         
      atrDefinition = iATR(_Symbol,PERIOD_M15, m_longMAPeriod - m_shortMAPeriod);
      if(atrDefinition == INVALID_HANDLE)
         return false;
         
      ChartIndicatorAdd(0, 0, shortMADefinition);
      ChartIndicatorAdd(0, 0, longMADefinition);
         
      ArraySetAsSeries(shortMAArray, true);
      ArraySetAsSeries(longMAArray, true);
      ArraySetAsSeries(priceArray, true);
      
      return true;
   }

   // Execute trades if all conditions are met
   void ExecuteStrategy() override
   {
      if (EntryCriteria())
      {
         EnterTrade(CheckMACrossover());
      }         
      ResetControlVariables();
   }
};