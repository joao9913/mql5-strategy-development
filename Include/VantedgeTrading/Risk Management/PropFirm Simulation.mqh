//+------------------------------------------------------------------+
//|                                          PropFirm Simulation.mqh |
//|                                         Copyright 2025, YourName |
//|                                                 https://mql5.com |
//| 20.09.2025 - Initial release                                     |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, YourName"
#property link "https://mql5.com"

#include "WriteToCSV.mqh";

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
   datetime m_phaseStartTime;
   datetime phaseEndTime;
   
   double maxDailyEquity;
   double minDailyEquity;
   datetime lastDay;
   CWriteToCSV csv;
   
public:
   //Constructor
   CPropFirmSimulation(double startBalance = 10000.0, double maxDD = 1000.0, double profitTarget = 800.0, double dailyDD = 500.0, int phase = 1)
   {
      csv.Init();
      
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
      m_phaseStartTime = TimeCurrent();
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
            UpdateChallenge("Failed");
            return;
         }
      }
      
      //Check Profit Target & Max Drawdown
      if(currentEquity <= m_maxDrawdown)
      {
         phaseEndTime = TimeCurrent();
         UpdateChallenge("Failed");
         return;
      }
      else if(currentEquity >= m_profitTarget && m_phase != 3)  
      {
         phaseEndTime = TimeCurrent();
         UpdateChallenge("Passed");
         return;
      }
   }
   
   //Reset challenge after passing or failing
   void UpdateChallenge(string outcome)
   {
      if(outcome == "Failed")
      {
         m_phase = 1;
         m_profitTargetValue = 800;
         ResetChallenge();
      }
      else if(outcome == "Passed")
      {
         if(m_phase == 1)
         {
            m_profitTargetValue = 500;
            m_phase = 2;
            ResetChallenge();
         }
         else if(m_phase == 2)
         {
            m_profitTargetValue = 0;
            m_profitTarget = 0;
            m_phase = 3;
            ResetChallenge();
         }
      }
      else if(outcome == "Payout")
      {
         ResetChallenge();
      }
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
      
      datetime currentTime = TimeCurrent();
      int daysPassed = (int)((currentTime - m_phaseStartTime) / 86400);
      
      //Check If Payout
      if(m_phase == 3)
      {
         if(daysPassed >= 14)
         {
            if(m_currentBalance > m_startBalance)
            {
               UpdateChallenge("Payout");
            }
         }
      }
   }
   
   //Reset Balance & Targets
   void ResetChallenge()
   {
      string row[] = {
         TimeToString(m_phaseStartTime, TIME_DATE),
         TimeToString(phaseEndTime, TIME_DATE)
      };
      
      csv.WriteCSV(row);
   
      m_phaseStartTime = TimeCurrent();
      m_startBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      m_currentBalance = m_startBalance;
      m_maxDrawdown = m_startBalance - m_maxDrawdownValue;
      m_profitTarget = m_startBalance + m_profitTargetValue;
   }
}