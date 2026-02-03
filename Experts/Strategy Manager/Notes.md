# Strategy Manager

Modular MQL5 Expert Advisor designed to orchestrate multiple trading strategies within a single, configurable framework.
It enables both live trading and simulation-based testing, including prop-firm style RnD simulations and risk management. The system abstracts strategy logic from execution, making it modular and testable.
This module emphasises:
 - Modular & reusable strategy architecture
 - Centralised management
 - Simulation framework for prop-firm environments
 - Configurable design

# Features
 - Multiple strategy support - loads and executes any strategy dynamically using a single EA
 - Simulation framwork integration - run prop firm simulations, including "EDGE" risk scaling and historical scenario testing
 - Dynamic risk management - supports fixed risk, dynamic risk scaling (EDGE) and compounding
 - Configurable settings - Global, strategy specific and simulation specific input parameters
 - Trade transaction hooks - tracks wins/losses and updates simulation state automatically

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
1. On initialization (OnInit):
  - Sets global variables
  - Load selected strategy
  - Initializes prop firm simulations if enabled

2. On each tick (OnTick):
  - Executes the selected strategy
  - Adjusts risk according to simulation or fixed risk
  - Updates simulation / EDGE state

3. On trade transacations (OnTradeTransaction):
  - Detects closed trades
  - Updates simulation results and EDGE calculations
  - Tracks wins, losses and stop-loss/take-profit triggers

4. On deinitialization (OnDeInit):
  - Cleans up strategy and simulation objects
  - Frees memory

# Architecture Highlights
  - CStrategy Base Class - all strategies inherit from a shared interface
  - Strategy Manager EA - handles input, dynamic loading and execution
  - CPropFirmSimulation - simulates account behaviour under prop firm constraints
  - EDGERiskScaling - adjusts position sizing based on recent trade outcomes
  - Modular Design - adding a new strategy requires minimal changes

# Skills
This module showcases:
  - MQL5 Expertise: classes, inheritance, modular EAs
  - Algorithmic trading system design
  - Simulation frameworks for testing robustness
  - Risk management design for live trading constraints
  - Code maintainability and production-quality practices