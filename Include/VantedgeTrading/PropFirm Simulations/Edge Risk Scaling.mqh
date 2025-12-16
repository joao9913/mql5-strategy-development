//+------------------------------------------------------------------+
//|                                            EDGE Risk Scaling.mqh |
//|                                         Copyright 2025, YourName |
//|                                                 https://mql5.com |
//| 20.09.2025 - Initial release                                     |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, YourName"
#property link "https://mql5.com"

class CEdgeRiskScaling
{
private:
   int m_phase;
   int m_stage;
   int m_trade;
   
   //Risk tables for phase 1
   double m_phase1Stage1[4];
   double m_phase1Stage2[5];
   double m_phase1Stage3[5];
   
   //Risk tables for phase 2 & phase 3
   double m_phase2Stage1[5];
   double m_phase2Stage2[5];
   double m_phase2Stage3[6];

public:
   CEdgeRiskScaling(int phase = 1)
   {
      m_phase = phase;
      m_stage = 1;
      m_trade = 1;
      
      //PHASE 1
      m_phase1Stage1[0] = 1.50;
      m_phase1Stage1[1] = 2.25;
      m_phase1Stage1[2] = 3.38;
      m_phase1Stage1[3] = 3.56;
      
      m_phase1Stage2[0] = 1.10;
      m_phase1Stage2[1] = 1.65;
      m_phase1Stage2[2] = 2.48;
      m_phase1Stage2[3] = 3.71;
      m_phase1Stage2[4] = 4.47;
      
      m_phase1Stage3[0] = 1.40;
      m_phase1Stage3[1] = 2.10;
      m_phase1Stage3[2] = 3.15;
      m_phase1Stage3[3] = 3.33;
      m_phase1Stage3[4] = 4.99;
      
      //PHASE 2
      m_phase2Stage1[0] = 0.85;
      m_phase2Stage1[1] = 1.28;
      m_phase2Stage1[2] = 1.91;
      m_phase2Stage1[3] = 2.87;
      m_phase2Stage1[4] = 3.45;
      
      m_phase2Stage2[0] = 0.96;
      m_phase2Stage2[1] = 1.44;
      m_phase2Stage2[2] = 2.16;
      m_phase2Stage2[3] = 3.24;
      m_phase2Stage2[4] = 3.90;
      
      m_phase2Stage3[0] = 0.69;
      m_phase2Stage3[1] = 1.04;
      m_phase2Stage3[2] = 1.55;
      m_phase2Stage3[3] = 2.33;
      m_phase2Stage3[4] = 3.49;
      m_phase2Stage3[5] = 4.55;
      
   }
   
   //Setter for PropFirm Simulations to set the current phase after passing/failing
   void SetCurrentPhase(int phase)
   {
      m_phase = phase;
      m_stage = 1;
      m_trade = 1;
   }
   
   //Update scaling based on trade result
   void UpdateScaling(bool win)
   {
      if(win && m_trade-1 >= 0)
      {
         if(m_phase == 1)
         {
            switch(m_stage)
            {
               case 1: 
                  if(m_trade-1 < 3) m_stage = 2;
                  m_trade = 1;
                  break;
                  
               case 2:
                  if(m_trade-1 < 4) m_stage = 3;
                  m_trade = 1;
                  break;
                  
               case 3:
                  if(m_trade-1 < 3) m_stage = 3;
                  m_trade = 1;
                  break;
            }
         }
         else if(m_phase == 2 || m_phase == 3)
         {
            switch(m_stage)
            {
               case 1: 
                  if(m_trade-1 < 4) m_stage = 2;
                  m_trade = 1;
                  break;
                  
               case 2:
                  if(m_trade-1 < 4) m_stage = 3;
                  m_trade = 1;
                  break;
                  
               case 3:
                  if(m_trade-1 < 4) m_stage = 3;
                  m_trade = 1;
                  break;
            }
         }
      }
      else if(!win && m_trade-1 >= 0)
      {
         if(CheckIfLastTrade())
            m_trade++;
         
         if(m_phase == 1)
         {
            switch(m_stage)
            {
               case 1:
                  if(m_trade-1 >= 4) m_trade = 1;
                  break;
                  
               case 2:
                  if(m_trade-1 >= 5) m_trade = 1;
                  break;
                  
               case 3:
                  if(m_trade-1 >= 5) m_trade = 1;
                  break;
            }
         }
         else if(m_phase == 2 || m_phase == 3)
         {
            switch(m_stage)
            {
               case 1:
                  if(m_trade-1 >= 5) m_trade = 1;
                  break;
                  
               case 2:
                  if(m_trade-1 >= 5) m_trade = 1;
                  break;
                  
               case 3:
                  if(m_trade-1 >= 6) m_trade = 1;
                  break;
            }
         }
      }  
   }
   
   bool CheckIfLastTrade()
   {
      if(m_phase == 1)
      {
         switch(m_stage)
         {
            case 1:
               if(m_trade == 4)
                  return false;
            case 2:
               if(m_trade == 5)
                  return false;
            case 3:
               if(m_trade == 5)
                  return false;
         }
      }
      else if(m_phase == 2 || m_phase == 3)
      {
         switch(m_stage)
         {
            case 1:
               if(m_trade == 5)
                  return false;
            case 2:
               if(m_trade == 5)
                  return false;
            case 3:
               if(m_trade == 6)
                  return false;
         }
      }
      
      return true;
   }
   

   //Getter for risk
   double GetRisk()
   {
      switch(m_phase)
      {
         case 1:
            switch(m_stage)
            {
               case 1: return m_phase1Stage1[m_trade-1];
               case 2: return m_phase1Stage2[m_trade-1];
               case 3: return m_phase1Stage3[m_trade-1];
               default: return 0.0;
            }
              
         case 2:
            switch(m_stage)
            {
               case 1: return m_phase2Stage1[m_trade-1];
               case 2: return m_phase2Stage2[m_trade-1];
               case 3: return m_phase2Stage3[m_trade-1];
               default: return 0.0;
            }
            
         case 3:
            switch(m_stage)
            {
               case 1: return m_phase2Stage1[m_trade-1];
               case 2: return m_phase2Stage2[m_trade-1];
               case 3: return m_phase2Stage3[m_trade-1];
               default: return 0.0;
            } 
         
         default: return 0.0;
      }
   }
   
   //Return two wins
   int PayoutStage()
   {
      return m_stage;
   }
}