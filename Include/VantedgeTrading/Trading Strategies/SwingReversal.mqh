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

   //--------METHODS

private:
   
   // Check if the entry criteria are met
   bool EntryCriteria() override
   {
      if (tradingAllowed && CheckActiveTimeRange() /* and any other entry criterias*/)
      
            return true;
      }

      return false;
   }

   // Enter market order on close direction
   void EnterTrade()
   {
      rr = 2.05;

      tradingAllowed = false;
   }

public:
   // Constructor for input variables
   SwingReversal()
   { 
   
   }

   // Execute trades if all conditions are met
   void ExecuteStrategy() override
   {
      if (EntryCriteria())
         EnterTrade();

      ResetControlVariables();
   }
};