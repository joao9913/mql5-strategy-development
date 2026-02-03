# Portfolio Manager

Production-ready MQL5 EA designed to manage and execute a portfolio of trading strategies on live accounts, with focus on prop-firms.
This EA abstracts strategy logic from account and risk management, allowing multiple strategies to operate simultaneously under configurable risk and allocation rules.
Key goals:
    - Execute validated strategies on live accounts
    - Apply risk scaling and position sizing across a portfolio
    - Track account phases (Challenge, Verification, Funded)
    - Enable consistent, automated trading while maintaining flexibility

# Features
 - Multiple strategy support - currently supports three, but modular design allows future strategy additions.
 - Prop firm account tracking - adjusts trade risk dynamically depending on account phase and remaining capital
  - Portfolio risk management - divides risk across multiple strategies, allows overrides for custom sizing if needed.
  - Timeframe validation - ensures strategies are running on the correct chart timeframe.
  - Dynamic strategy initialization - automatically selects and initializes strategy based on input parameters

 # Input Parameters

 ## Account Settings
  - AccountPhase - current prop firm account phase
  - StrategyChoice - which strategy to execute
  - AccountBalance -  starting account balance
  - ServerHourDifference - broker server offset
  - RiskOverride - override risk calculations
  - RiskDivisionOverride - override number of strategies used for risk calculations

# How It Works
1. On initialization (OnInit):
  - Sets global variables
  - Load selected strategy
  - Validates strategy required timeframe
  - Sets up portfolio risk management using CPropFirmTracker

2. On each tick (OnTick):
  - Checks risk and tracking status
  - Executes strategy if conditions are met
  - Updates portfolio-level risk in real time

3. On deinitialization (OnDeInit):
  - Cleans up strategy and simulation objects
  - Frees memory

# Architecture Highlights
  - CStrategy Base Class - all strategies inherit from a shared interface
  - Portfolio Manager EA - handles account orchestration, strategy initialization and risk distribution
  - Modular Design - easy to add new strategies or change risk allocation logic without rewriting core EA

# Skills
This module showcases:
  - Production-level MQL5 development for live trading
  - Portfolio-level risk and position management
  - Integration of multiple strategies under a single orchestrator
  - Real world trading execution under strict prop firm rules
  - Ability to build maintainable, modular trading systems