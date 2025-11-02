//+------------------------------------------------------------------+
//|                                             StrategyTemplate.mqh |
//|                                            VantedgeTrading, 2025 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "VantedgeTrading, 2025"
#property link "https://www.mql5.com"

#include "Strategy.mqh"

class StrategyName : public CStrategy
{
   //--------VARIABLES

private:
   // Member input variables

   //--------METHODS

private:
   
   // Check if the entry criteria are met
   bool EntryCriteria() override
   {
      if (tradingAllowed /* and any other entry criterias*/)
      
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
   StrategyName()
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