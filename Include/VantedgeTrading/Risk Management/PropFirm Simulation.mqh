//+------------------------------------------------------------------+
//|                                          PropFirm Simulation.mqh |
//|                                         Copyright 2025, YourName |
//|                                                 https://mql5.com |
//| 20.09.2025 - Initial release                                     |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, YourName"
#property link "https://mql5.com"

class CPropFirmSimulation
{
private:
   //Core parameters
   double m_startBalance;
   double m_balance;
   double m_equityHigh;
   
   double m_maxDrawdownPct;
   double m_profitTargetPct;
   double m_maxDailyDDPct;
   datetime lastDay;
   double equityLowest;
   double equityHighest;
   
   int m_phase;   //1 = Challenge, 2 = Verification, 3 = Funded
   int m_tradeCount;

public:
   //Constructor
   CPropFirmSimulation(double startBalance = 10000.0,
                       double maxDD = 10.0,
                       double profitTarget = 8.0,
                       double dailyDD = 5.0)
   {
      m_startBalance = startBalance;
      m_balance = startBalance;
      m_equityHigh = startBalance;
      m_maxDrawdownPct = maxDD;
      m_profitTargetPct = profitTarget;
      m_maxDailyDDPct = dailyDD;
      m_phase = 1;
      m_tradeCount = 0;
   }
   
   //LOGIC IS WRONG. IF DIFFERENCE > 5% DOESNT MAKE SENSE
   //Method to reset equity highest and lowest
   void ResetEquityHighLow()
   {
      double dailyDDPct = NormalizeDouble(100.0 * (equityHighest - equityLowest) / equityHighest, 2);
    
      if(dailyDDPct >= m_maxDailyDDPct)
         ResetForNextPhase("Failed");
            
      Comment("Equity Highest: ", equityHighest, "\n", 
                 "Equity Lowest: ", equityLowest, "\n", 
                 "Daily DD: ", dailyDDPct, "\n",
                 "\nMax Daily DD: ", m_maxDailyDDPct);
                 
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      equityHighest = equity;
      equityLowest = equity;
   }
   
   //Update Equity Highest and Lowest
   void UpdateDailyEquity()
   {
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      datetime currentDay = iTime(_Symbol, PERIOD_D1, 0);   //Get current day (midnight timestamp)
      
      //Reset equity high and low at new day
      if(currentDay != lastDay)
      {                           
         lastDay = currentDay;
         ResetEquityHighLow();
         return;
      }
      
      if(equity > equityHighest)
         equityHighest = equity;
      
      if(equity < equityLowest)
         equityLowest = equity;
   }
   
   //Reset when new phase starts
   void ResetForNextPhase(string phaseOutcome)
   {  
      m_startBalance = m_balance;
      m_equityHigh = m_balance;
      m_tradeCount = 0;
      
      if(phaseOutcome == "Failed")
      {
         m_phase = 1;
         TesterStop();
      }
      else if(phaseOutcome == "Passed")
      {
         if(m_phase < 3)
         {
            m_phase++;
            m_profitTargetPct = 5;
         }
      }
   }
   
   //Update balance after each trade outcome
   void UpdateBalance(double profit, string outcome)
   {
      ResetEquityHighLow();
      m_balance += profit;
      
      if(m_balance > m_equityHigh)
         m_equityHigh = m_balance;
         
      double ddPct = 100.00 * (1.0 - (m_balance / m_equityHigh));
      if(ddPct >= m_maxDrawdownPct)
         ResetForNextPhase("Failed");
       
      double profitPct = 100.0 * ((m_balance - m_startBalance) / m_startBalance);
      if(profitPct >= m_profitTargetPct && m_phase < 3)
         ResetForNextPhase("Passed");
   }
}