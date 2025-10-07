//+------------------------------------------------------------------+
//|                                               PushSimulation.mqh |
//|                                         Copyright 2025, YourName |
//|                                                 https://mql5.com |
//| 20.09.2025 - Initial release                                     |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, YourName"
#property link "https://mql5.com"

class CPushSimulation
{
private:
   double m_riskPercentage;

public:
   CPushSimulation(double initialRisk = 1.4)
   {
      m_riskPercentage = initialRisk;
   }

   // Get Risk
   double GetRisk()
   {
      return m_riskPercentage;
   }
}