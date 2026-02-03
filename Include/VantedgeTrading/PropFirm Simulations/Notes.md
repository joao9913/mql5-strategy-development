# Prop Firm Simulations

Simulation framework designed to model prop firm trading challenges and test strategies under realistic account constraints. It allows developers and traders to:
    - Run RnD simulations of trading strategies
    - Test risk scaling logic across challenge phases
    - Track performance and output CSV reports for analysis
The framework supports phase-based trading simulations (Phase1, Phase2 and Funded) with configurable risk, drawdowns and payout logic. It is tightly integrated with the Strategy Manager EA but can also be used as a standalone simulation tool.

# Modules

1. EDGE Risk Scaling.mqh
    - Handles dynamic risk scaling for trades in prop firm challenge simulations
    - Implements phase and stage specific risk tables for Phase1, Phase2 and Funded
    - Updates risk based on trade outcomes (win or loss)
    - Key class: CEdgeRiskScaling

2. PropFirm Simulation.mqh
    - Core simulation engine for prop firm challenges
    - Tracks account equity, max drawdown, daily drawdown and profit targets
    - Supports normal and EDGE-style risk scaling
    - Integrates CEdgeRiskScaling to adjust trade risk dynamically
    - Outputs simulation results to CSV via CWriteToCSV
    - Key class: CPropFirmSimulations

3. WriteToCSV.mqh
    - Handles csv reporting for simulations
    - Creates folders and files automatically, with timestamps, strategy names and risk levels
    - Records challenge number, phase start/end dates, balances, drawdowns and outcomes
    - Key class: CWriteToCSV

 # Input Parameters

 ## Global Settings
  - ServerHourDifference - offset between broker server and local time
  - StartingAccountBalance - starting balance for simulations
  - UseCompounding - enables risk commpounding
  - RiskOverride - override default risk for manual testing
  - VisualMode - enables drawings and visuals for strategy specific implementations
  - DebuggingMode - enable debugging execution and logs for fixing bugs and errors
  - StrategyChoice - chooses which strategy to execute

## Simulation Settings
  - RunSimulation - enables simulation mode
  - PhaseRun - simulation phase (1, 2 or funded)
  - DailyDrawdownTrailing - track daily drawdown based on equity
  - SaveCSVFiles - enables saving of each run csv files
  - RunEDGE - enable EDGE risk scaling methodology

## Strategy Specific Inputs
Each strategy has its own parameters depending on their own logic. Examples:
  - HourBreakout: RangeBars, EntryHour
  - OffsetMA: MAPeriod, OffsetPercentage, ATRMultiplier
  - MARetest: MAPerod, Lookback, ATRMultiplier
  
# How It Works
1. Initialize Simulation
    - Choose simulation mode (P1, P2 P3, Challenge, Funded)
    - Set starting balance and strategy name
    - Enable options: daily drawdown trailing, CSV saving, EDGE simulation

2. Run Simulation (On Tick)
    - Track account equity and drawdowns
    - Check profit targets and max drawdowns
    - Update risk dynamically using CEdgeRiskScaling
    - Handle payouts or phase transitions

3. Output Results
    - Simulation data is saved to CSV files for analysis
    - Includes start/end balance, drawdowns, duration and outcomes

# Features
    - Phase-based risk management - models phase 1, phase 2 and funded stages
    - Dynamic risk scaling - adjusts trade size automatically based on stage, phase and trade outcomes
    - Daily drawdown tracking - supports daily drawdown tracking to manage prop firm challenges
    - Automated csv reporting - keeps structured logs of simulation runs for review and testing
    - EDGE simulation mode - applies a risk scaling plan to normal simulations

# Skills
This module showcases:
  - MQL5 Expertise: classes, inheritance, modular EAs
  - Algorithmic trading system design
  - Simulation frameworks for testing robustness
  - Risk management design for live trading constraints
  - Code maintainability and production-quality practices