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
   int m_lookback;
   int m_neighbours;
   
   //--------METHODS

private:
   
   double highestHigh;
   int highIndex;
   
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
      double high = iHigh(_Symbol, PERIOD_CURRENT, 1);
      
      highestHigh = high;
      highIndex = 1;
      
      for(int i = 2; i < m_lookback; i++)
      {
         high = iHigh(_Symbol, PERIOD_CURRENT, i);
         
         if(high > highestHigh)
         {
            highestHigh = high;
            highIndex = i;
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
      ObjectCreate(0, prefix + "HLine", OBJ_HLINE, 0, TimeCurrent(), highestHigh);
      
      ChartRedraw(0); 
   }

public:
   // Constructor for input variables
   SwingReversal(int lookback, int neighbours)
   { 
      m_lookback = lookback;
      m_neighbours = neighbours;
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