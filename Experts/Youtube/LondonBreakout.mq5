//+------------------------------------------------------------------+
//|                                               LondonBreakout.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>

CTrade trade;


// INPUT VARIABLIES

input int entryHour = 10;
input int numberBars = 10;
input int closeHour = 11;
input double MaxRangeSize = 1;
input double MinRangeSize = 1;
input int atrPeriod = 24;

input bool Drawings = false;
input int hourDifference = 2;
input int accountBalance = 10000;
input double risk = 1;


// GLOBAL VARIABLES

double rangeTop = 0;
double rangeBottom = 0;
bool calculatedRange = false;
ulong orderTicket = 0;

int hour, minute = 0;
MqlDateTime currentTime;
datetime lastAction = 0;

int atrDefinition = iATR(Symbol(),PERIOD_CURRENT, atrPeriod);
double priceArray[];
double atr = 0;

int OnInit()
{
   return(INIT_SUCCEEDED);
}
  
void OnTick()
{
   GetAtrValue();
   ResetDay();
   CalculateRange();
   Breakout();
}

void GetAtrValue()
{
   ArraySetAsSeries(priceArray, true);
   CopyBuffer(atrDefinition, 0, 0, 3, priceArray);
   atr = NormalizeDouble(priceArray[0], _Digits);
}

void Breakout()
{
   if(calculatedRange && PositionsTotal() == 0)
   {
      double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double entryprice, stoploss, takeprofit;
      
      if(currentPrice > rangeTop)
      {
         entryprice = currentPrice;
         stoploss = rangeBottom;
         takeprofit = NormalizeDouble(entryprice + (entryprice - stoploss) * 2, _Digits);
         
         trade.Buy(calculateLots(stoploss, entryprice), _Symbol, entryprice, stoploss, takeprofit);
         orderTicket = trade.ResultOrder();
         
         calculatedRange = false;
      }
      else if(currentPrice < rangeBottom)
      {
         entryprice = currentPrice;
         stoploss = rangeTop;
         takeprofit = NormalizeDouble(entryprice - (stoploss - entryprice) * 2, _Digits);
         
         trade.Sell(calculateLots(stoploss, entryprice), _Symbol, entryprice, stoploss, takeprofit);
         orderTicket = trade.ResultOrder();
         
         calculatedRange = false;
      }
   }
}

void CancelOrder()
{
   if(hour == closeHour + hourDifference)
   {
      calculatedRange = false;
      trade.PositionClose(orderTicket);
   }
}

void CalculateRange()
{
   if(CheckEntryHour())
   {
      double high = iHigh(_Symbol, PERIOD_CURRENT, 1);
      double low = iLow(_Symbol, PERIOD_CURRENT, 1);
      
      for(int i = 1; i <= numberBars; i++)
      {
         low = iLow(_Symbol, PERIOD_CURRENT, i);
         high = iHigh(_Symbol, PERIOD_CURRENT, i);
         
         if(rangeTop == 0 || rangeBottom == 0)
         {
            rangeTop = high;
            rangeBottom = low;
         }
         
         if(low < rangeBottom)
            rangeBottom = low;
         
         if(high > rangeTop)
            rangeTop = high;
      }
      
      drawRange(rangeTop, rangeBottom);
      
      double rangeSize = NormalizeDouble((rangeTop - rangeBottom) * 1000, 2);
      double minimumRangeSize = NormalizeDouble((atr * MinRangeSize) * 1000, 2);
      double maximumRangeSize = NormalizeDouble((atr * MaxRangeSize) * 1000, 2);
      
      if(rangeSize < maximumRangeSize && rangeSize > minimumRangeSize)
      {
         calculatedRange = true;
      }
   }
}

void drawRange(double top, double bottom)
{
   datetime startRange[];
   
   CopyTime(Symbol(), PERIOD_CURRENT, 1, numberBars, startRange);
   ObjectCreate(0, "Range", OBJ_RECTANGLE, 0, startRange[0], top, TimeCurrent(), bottom);
   ObjectSetInteger(0, "Range", OBJPROP_COLOR, clrCyan);
   ObjectSetInteger(0, "Range", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, "Range", OBJPROP_WIDTH, 1);
}

bool CheckEntryHour()
{
   MqlRates priceData[];
   TimeCurrent(currentTime);
   hour = currentTime.hour;
   minute = currentTime.min;
   
   if(hour == entryHour + hourDifference && minute == 0)
   {
      return true;
   }

   return false;
}

static datetime today = iTime(_Symbol, PERIOD_D1, 0);

void ResetDay()
{
   // new day
   if(today != iTime(_Symbol, PERIOD_D1, 0) && PositionsTotal() == 0)
   {
      today = iTime(_Symbol, PERIOD_D1, 0);
      rangeBottom = 0;
      rangeTop = 0;
      calculatedRange = false;
   }
   
   CancelOrder();
}

double calculateLots(double stopLoss, double entryPrice)
{   
   double slDistance = MathAbs(stopLoss - entryPrice);
   double pointSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT); // Point size instead of tick size
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE); // Tick value
   
   double lotSize = (risk / 100.0) * accountBalance / (slDistance * tickValue / pointSize);
   double minLotSize = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLotSize = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   
   lotSize = MathMax(lotSize, minLotSize);
   lotSize = MathMin(lotSize, maxLotSize);
   
   return NormalizeDouble(lotSize,2);   
}