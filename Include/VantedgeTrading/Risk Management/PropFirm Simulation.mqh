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
   double m_currentBalance;
   double m_maxDrawdownValue;
   double m_maxDrawdown;
   double m_profitTargetValue;
   double m_profitTarget;
   double m_maxDailyDrawdown;
   int m_phase;
   
   double maxDailyEquity;
   double minDailyEquity;
   datetime lastDay;
   
public:
   //Constructor
   CPropFirmSimulation(double startBalance = 10000.0, double maxDD = 1000.0, double profitTarget = 800.0, double dailyDD = 500.0, int phase = 1)
   {
      m_startBalance = startBalance;
      m_maxDrawdownValue = maxDD;
      m_maxDrawdown = NormalizeDouble(m_startBalance - m_maxDrawdownValue, 2);
      m_profitTargetValue = profitTarget;
      m_profitTarget = NormalizeDouble(m_startBalance + profitTarget, 2);
      m_maxDailyDrawdown = dailyDD;
      m_phase = phase;
      maxDailyEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      minDailyEquity = maxDailyEquity;
      lastDay = iTime(_Symbol, PERIOD_D1, 0);
   }
   
   //Update challenge status each tick
   void UpdateChallengeStatus()
   {
      double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      
      //If new day, reset highest and lowest daily equity
      ResetDailyDrawdown(currentEquity);
      
      //Check Daily Drawdown
      if(currentEquity > maxDailyEquity)
         maxDailyEquity = currentEquity;
      else if(currentEquity < minDailyEquity)
      {
         minDailyEquity = currentEquity;
         double difference = maxDailyEquity - minDailyEquity;
         if(difference >= m_maxDailyDrawdown)
         {
            CommentInformation(currentEquity, "Failed - Max Daily Drawdown");
            ResetChallenge("Failed - Max Daily Drawdown");
            return;
         }
      }
      
      //Check Profit Target & Max Drawdown
      if(currentEquity <= m_maxDrawdown)
      {
         CommentInformation(currentEquity, "Failed - Max Drawdown");
         ResetChallenge("Failed - Max Drawdown");
         return;
      }
      else if(currentEquity >= m_profitTarget)  
      {
         CommentInformation(currentEquity, "Passed - Profit Target");
         ResetChallenge("Passed - Profit Target");
         return;
      }
   }
   
   //Reset challenge after passing or failing
   void ResetChallenge(string outcome)
   {
      m_startBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      m_maxDrawdown = m_startBalance - m_maxDrawdownValue;
      m_profitTarget = m_startBalance + m_profitTargetValue;
      m_phase = 1;
      
      //Add logic for next phases
   }
   
   //Reset daily drawdown equity
   void ResetDailyDrawdown(double equity)
   {
      datetime currentDay = iTime(_Symbol, PERIOD_D1, 0);   //Get current day (midnight timestamp)
      
      //Reset daily equity high and low at new day
      if(currentDay != lastDay)
      {  
         lastDay = currentDay;
         maxDailyEquity = equity;
         minDailyEquity = equity;
      }
   }
      
   //Update balance after each trade outcome
   void UpdateBalance(double profit)
   {      
      m_currentBalance += profit;
      m_currentBalance = NormalizeDouble(m_currentBalance, 2);
   }
   
   //Comment Information
   void CommentInformation(double equity, string outcome)
   {
      double difference =NormalizeDouble(maxDailyEquity - minDailyEquity, 2);
      
      Comment("Start Balance: ", m_startBalance, "\n",
              "Current Balance: ", m_currentBalance, "\n",
              "Max Drawdown: ", m_maxDrawdown, "\n",
              "Profit Target: ", m_profitTarget, "\n",
              "Max Daily Drawdown: ", m_maxDailyDrawdown, "\n",
              "Daily Drawdown: ", difference, "\n",
              "Current Equity: ", equity, "\n",
              "\nOutcome: ", outcome, "\n");
   }
}