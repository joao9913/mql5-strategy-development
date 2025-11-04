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
   double minimumBalance;
   double targetBalance;
   string lastOutcome;
   string outcomeReason;
      
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
            
            Comment("Daily DD Pct: ", dailyDDPct, "\n",
                    "Daily Equity High: ", dailyEquityHighest, "\n",
                    "Daily Equity Low: ", dailyEquityLowest, "\n",
                    "Max Daily DD Pt: ", m_maxDailyDDPct, "\n");
            outcomeReason = "Daily Drawdown";
            TesterStop();
            ResetForNextPhase("Failed");
         }
      }
      
      //Account max drawdown with equity
      if(equity < m_accountEquityLow)
      {
         m_accountEquityLow = equity;
         
         double ddPct = NormalizeDouble(100.00 * (1.0 - (m_accountEquityLow / m_accountEquityHigh)), 1);
         if(ddPct > m_maxDrawdownPct)
         {                    
            ResetForNextPhase("Failed");
            outcomeReason = "Maximum Drawdown";
            CommentInformation(0);
            return;
         }
      }
   }
   
   //Reset when new phase starts
   void ResetForNextPhase(string phaseOutcome)
   {  
      m_startBalance = m_balance;
      lastOutcome = phaseOutcome;
      minimumBalance = NormalizeDouble(m_startBalance * (1.0 - m_maxDrawdownPct / 100.0),2);
      targetBalance = NormalizeDouble(m_startBalance * (1.0 + m_profitTargetPct / 100.0),2);
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
            m_profitTargetPct = 0;
            fundedStartDate = TimeCurrent();
            fundedEndDate = fundedStartDate + 14 * 86400;
         }
         else if(m_phase == 3)
         {
            fundedStartDate = TimeCurrent();
            fundedEndDate = fundedStartDate + 14 * 86400;
            m_profitTargetPct = 0;
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
               outcomeReason = "Payout Date";
            }
         }
      }
   }
      
   //Update balance after each trade outcome
   void UpdateBalance(double profit, string outcome)
   {      
      m_balance += profit;
      m_balance = NormalizeDouble(m_balance, 2);
            
      if(!minimumBalance)
      {
         minimumBalance = NormalizeDouble(m_startBalance * (1.0 - m_maxDrawdownPct / 100.0),2);
         targetBalance = NormalizeDouble(m_startBalance * (1.0 + m_profitTargetPct / 100.0),2);
      }
      
      if(m_balance > m_accountEquityHigh)
         m_accountEquityHigh = m_balance;
       
      if(m_balance >= targetBalance)
      {
         ResetForNextPhase("Passed");
         outcomeReason = "Profit Target";
         CommentInformation(profit);
         return;
      }
         
      ResetEquityHighLow();
      FundedStage();
      CommentInformation(profit);
   }
   
   //Comment information regarding the simulation
   void CommentInformation(double profit)
   {
      Comment("Starting Balance: ", m_startBalance, "\n",
              "Current Balance: ", m_balance, "\n",
              "Minimum Balance: ", minimumBalance, "\n",
              "Target Balance: ", targetBalance, "\n\n",
              "Current Phase: ", m_phase, "\n"
              "Last Trade: ", profit, "\n",
              "Last Outcome: ", lastOutcome, "| ", outcomeReason, "\n");
   }
}