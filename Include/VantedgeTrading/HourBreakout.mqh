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
   int m_rangeBars;
   int m_entryHour;

   double rangeHigh;
   double rangeLow;

   //--------METHODS

private:
   // Method for checking if hour is within entry hour range
   bool CheckEntryHour()
   {
      // Set variables and get current hour and minute
      MqlRates priceData[];
      MqlDateTime currentTime;
      TimeCurrent(currentTime);
      int currentHour = currentTime.hour;
      int currentMinute = currentTime.min;

      if (currentHour == m_entryHour + m_ServerHourDifference && currentMinute <= 5)
      {
         return true;
      }

      return false;
   }

   // Method for calculating range
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

   // Method to check if the entry criteria are met
   bool EntryCriteria() override
   {
      if (CheckEntryHour())
      {
         CalculateRange();
         return true;
      }

      return false;
   }

public:
   // Constructor for input variables
   HourBreakout(int rangeBars, int entryHour, int serverHourDifference)
   {
      m_rangeBars = rangeBars;
      m_entryHour = entryHour;
      m_ServerHourDifference = serverHourDifference;
   }

   void ExecuteTrade() override
   {
      if (EntryCriteria())
      {
      }
   }
};