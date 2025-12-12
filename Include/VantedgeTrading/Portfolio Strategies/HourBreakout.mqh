//+------------------------------------------------------------------+
//|                                                 HourBreakout.mqh |
//|                                            VantedgeTrading, 2025 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "VantedgeTrading, 2025"
#property link "https://www.mql5.com"

#include "Strategy.mqh"

class HourBreakout : public CStrategy
{
   //--------VARIABLES

private:
   // Member input variables
   int m_rangeBars;
   int m_entryHour;

   // Range variables to use when entering orders
   double rangeHigh;
   double rangeLow;

   //--------METHODS

private:
   // Check if hour is within entry hour range
   bool CheckEntryHour()
   {
      if (GetCurrentHour() == m_entryHour + m_ServerHourDifference && GetCurrentMinute() <= 5)
         return true;

      return false;
   }
   
   bool CheckTimeframe() override
   {
      ENUM_TIMEFRAMES period = Period();
      if(period == PERIOD_H1)
         return true;
       
      return false;
   }
   
   void VisualMode() override
   {
      string prefix = m_objPrefix + "_HOURBREAKOUT";
      
      if(CheckEntryHour())
      {
         //Draw Range
         datetime timeStart = iTime(_Symbol, PERIOD_CURRENT, m_rangeBars);
         datetime timeEnd = iTime(_Symbol, PERIOD_CURRENT, 0);
         
         ObjectCreate(0, prefix + "Range", OBJ_RECTANGLE, 0, timeStart, rangeHigh, timeEnd, rangeLow);
         ObjectSetInteger(0, prefix + "Range", OBJPROP_COLOR, clrMediumSpringGreen);
         ObjectSetInteger(0, prefix + "Range", OBJPROP_BACK, true);
         
         //Draw Entry Lines
         ObjectCreate(0, prefix + "EntryHour", OBJ_VLINE, 0, timeStart, rangeHigh);
         ObjectSetInteger(0, prefix+"EntryHour", OBJPROP_COLOR, clrMaroon);
         
         ChartRedraw(0); 
      }
   }

   // Calculate range
   void CalculateRange()
   {
      double high = iHigh(Symbol(), PERIOD_CURRENT, 1);
      double low = iLow(Symbol(), PERIOD_CURRENT, 1);

      rangeHigh = high;
      rangeLow = low;

      for (int i = 1; i < m_rangeBars; i++)
      {
         low = iLow(Symbol(), 0, i);
         high = iHigh(Symbol(), 0, i);

         if (low < rangeLow)
            rangeLow = low;

         if (high > rangeHigh)
            rangeHigh = high;
      }
   }

   // Check if the entry criteria are met
   bool EntryCriteria() override
   {
      if (CheckEntryHour() && !CheckOpenTrades() && !CheckOpenOrders() && CheckTimeframe())
      {
         CalculateRange();
         ClearVisualMode();
         VisualMode();
      
         return true;
      }

      return false;
   }

   // Place pending orders with correct trade information
   void PlacePendings()
   {
      // Get symbol stop level
      int stopLevelPoints = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
      double stopLevelPrice = stopLevelPoints * _Point;

      // Get ask and bid price for current symbol
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      rr = 2.05;

      // Place long pending order
      entryprice = rangeHigh;
      stoploss = rangeLow;
      takeprofit = NormalizeDouble(entryprice + (entryprice - stoploss) * rr, _Digits);

      if (entryprice - ask < stopLevelPrice)
         entryprice = NormalizeDouble(ask + stopLevelPrice, _Digits);

      trade.BuyStop(CalculateLots(), entryprice, Symbol(), stoploss, takeprofit);

      // Place short pending order
      entryprice = rangeLow;
      stoploss = rangeHigh;
      takeprofit = NormalizeDouble(entryprice - (stoploss - entryprice) * 2.05, _Digits);

      if (bid - entryprice < stopLevelPrice)
         entryprice = NormalizeDouble(bid - stopLevelPrice, _Digits);

      trade.SellStop(CalculateLots(), entryprice, Symbol(), stoploss, takeprofit);
   }

   // Cancel pending order once opposite one is triggered
   void CancelPendingOrder()
   {
      if (CheckOpenTrades() && CheckOpenOrders())
         CancelOpenOrders();
   }

public:
   // Constructor for input variables
   HourBreakout()
   {
      if (_Symbol == "USDJPY")
      {
         m_rangeBars = 3;
         m_entryHour = 3;
         return;
      }
      else if (_Symbol == "GBPUSD")
      {
         m_rangeBars = 5;
         m_entryHour = 9;
         return;
      }
   }

   // Execute trades if all conditions are met
   void ExecuteStrategy() override
   {
      if(EntryCriteria())
      {  
         PlacePendings();
      }
      
      CancelPendingOrder();
   }
};