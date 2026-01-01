//+------------------------------------------------------------------+
//|                                                SwingReversal.mqh |
//|                                            VantedgeTrading, 2025 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "VantedgeTrading, 2025"
#property link "https://www.mql5.com"

#include "SwingReversal.mqh"

class SwingReversal : public CStrategy
{
   //--------VARIABLES

private:
   // Member input variables
   int m_neighbours;
   int m_lookback;
   
   //--------METHODS

private:
   
   double highestHigh;
   
   // Check if the entry criteria are met
   bool EntryCriteria() override
   {
      if (tradingAllowed && CheckActiveTimeRange() /* and any other entry criterias*/)
      {
            return true;
      }

      return false;
   }
   
   void GetLastSwingHigh()
   {  
      for(int i = m_neighbours; i <= m_lookback; i++)
      {         
         double currentHigh = iHigh(_Symbol, PERIOD_CURRENT, i);
         
         for(int k = i - 5; k <= i + 5; k++)
         {
            double high = iHigh(_Symbol, PERIOD_CURRENT, k);
            
            if(high > currentHigh)
               break;
         }
      }
   }

   // Enter market order on close direction
   void EnterTrade()
   {
      rr = 2.05;

      tradingAllowed = false;
   }
   
   void VisualMode() override
   {
      if(!m_visualMode) return;
      
      string prefix = m_objPrefix + "_SWINGREVERSAL";
      //ObjectCreate(0, prefix + "HLine", OBJ_HLINE, 0, TimeCurrent(), highestHigh);
      
      ChartRedraw(0); 
   }

public:
   // Constructor for input variables
   SwingReversal(int neighbours, int lookback)
   { 
      m_neighbours = neighbours;
      m_lookback = lookback;
   }

   // Execute trades if all conditions are met
   void ExecuteStrategy() override
   {
      GetLastSwingHigh();
      VisualMode();
      
      if (EntryCriteria())
      {
         EnterTrade();
         DebuggingMode();
      }

      ResetControlVariables();
   }
};