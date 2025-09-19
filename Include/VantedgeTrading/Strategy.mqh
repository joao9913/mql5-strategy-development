//+------------------------------------------------------------------+
//|                                                     Strategy.mqh |
//|                                            VantedgeTrading, 2025 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "VantedgeTrading, 2025"
#property link      "https://www.mql5.com"

#include <Trade\Trade.mqh>

class CStrategy
{
   //--------VARIABLES
   
   protected:
      int m_ServerHourDifference;
      CTrade trade;   
   
   //--------METHODS
      
   protected:      
      //Abstract method every strategy needs to implement
      virtual bool EntryCriteria() = 0;
          
            
      //Common methods that any child "Strategy" will use the same way
      
      //Calculate lots depending on stoploss, entryprice, risk, balance, symbol
      double CalculateLots(double stoploss, double entryprice, double risk, double balance)
      {
         double slDistance = MathAbs(stoploss - entryprice);
         double pointSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT); // Point size instead of tick size
         double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE); // Tick value
         double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
         double lotSize = (risk / 100.0) * balance / (slDistance * tickValue / pointSize);         
         lotSize = MathMax(lotSize, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN));
         lotSize = MathMin(lotSize, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX));
         
         lotSize = MathFloor(lotSize / lotStep) * lotStep;
         
         return lotSize;
      }
      
      //Check if there are any open orders or trades open
      bool CheckOpenPositions()
      {
         //Implementation
         return false;
      }
      
   public:      
      //Abstract method every strategy needs to implement
      virtual void ExecuteTrade() = 0;
      
      //Constructor for Server Hour Difference input
      CStrategy(int ServerHourDifference = 0)
      {
         m_ServerHourDifference = ServerHourDifference;
      }
      
};