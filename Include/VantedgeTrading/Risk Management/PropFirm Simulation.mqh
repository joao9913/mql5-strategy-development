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
   double m_accountEquityHigh;
   double m_accountEquityLow;
   double m_maxDrawdownPct;
   double m_profitTargetPct;
   double m_maxDailyDDPct;
   
   
   datetime lastDay;
   datetime fundedStartDate, fundedEndDate;
   double dailyEquityLowest;
   double dailyEquityHighest;
      
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
      m_accountEquityHigh = startBalance;
      m_accountEquityLow = startBalance;
      m_maxDrawdownPct = maxDD;
      m_profitTargetPct = profitTarget;
      m_maxDailyDDPct = dailyDD;
      m_phase = 1;
      m_tradeCount = 0;
   }
   
   //Method to reset equity highest and lowest
   void ResetEquityHighLow()
   {                 
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      dailyEquityHighest = equity;
      dailyEquityLowest = equity;
   }
   
   //Update Equity Every Tick
   void UpdateEquity()
   {
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      datetime currentDay = iTime(_Symbol, PERIOD_D1, 0);   //Get current day (midnight timestamp)
      
      //Reset daily equity high and low at new day
      if(currentDay != lastDay)
      {                           
         lastDay = currentDay;
         ResetEquityHighLow();
         return;
      }
      
      //Daily drawdown with equity
      
      if(equity > dailyEquityHighest)
         dailyEquityHighest = equity;
      
      if(equity < dailyEquityLowest)
      {
         dailyEquityLowest = equity;
         
         double dailyDDPct = NormalizeDouble(100.0 * (dailyEquityHighest - dailyEquityLowest) / dailyEquityHighest, 2);
    
         if(dailyDDPct >= m_maxDailyDDPct)
         {
            //FAILED DUE TO DAILY DRAWDOWN
            ResetForNextPhase("Failed");
         }
      }
      
      //Account max drawdown with equity
      if(equity < m_accountEquityLow)
         m_accountEquityLow = equity;
   }
   
   //Reset when new phase starts
   void ResetForNextPhase(string phaseOutcome)
   {  
      m_startBalance = m_balance;
      m_accountEquityLow = m_balance;
      m_accountEquityHigh = m_balance;
      m_tradeCount = 0;
      
      if(phaseOutcome == "Failed")
      {
         m_phase = 1;
      }
      else if(phaseOutcome == "Passed")
      {
         if(m_phase == 1)
         {
            m_phase++;
            m_profitTargetPct = 5;
         }
         else if(m_phase == 2)
         {
            m_phase++;
            m_profitTargetPct = 100;
            fundedStartDate = TimeCurrent();
            fundedEndDate = fundedStartDate + 14 * 86400;
         }
         else if(m_phase == 3)
         {
            fundedStartDate = TimeCurrent();
            fundedEndDate = fundedStartDate + 14 * 86400;
            m_profitTargetPct = 100;
         }
      }
   }
   
   //Funded stage payout logic
   void FundedStage()
   {
      if(m_phase == 3)
      {
         datetime currentDate = TimeCurrent();
         if(currentDate >= fundedEndDate)
         {
            if(m_balance < m_startBalance)
            { 
               ResetForNextPhase("Passed");
            }
         }
      }
   }
      
   //Update balance after each trade outcome
   void UpdateBalance(double profit, string outcome)
   {      
      m_balance += profit;
      
      if(m_balance > m_accountEquityHigh)
         m_accountEquityHigh = m_balance;
         
      double ddPct = NormalizeDouble(100.00 * (1.0 - (m_accountEquityLow / m_accountEquityHigh)), 2);
      if(ddPct >= m_maxDrawdownPct)
         ResetForNextPhase("Failed");
       
      double profitPct = 100.0 * ((m_balance - m_startBalance) / m_startBalance);
      if(profitPct >= m_profitTargetPct)
         ResetForNextPhase("Passed");
         
      ResetEquityHighLow();
      FundedStage();
   }
}