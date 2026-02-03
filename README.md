# Overview
Centralised research and development workspace for algorithmic trading systems, built primarily in MQL5. It contains production-quality code used to design, test and validate executable trading strategies, with a strong emphasis on long-term performance and prop-firm use.
The project reflects a hybrid approach between trader and developer: software engineering principles applied to real-world trading problems, including strategy orchestration, simulation-driven R&D and performance validation under realistic conditions.
The repository is actively developed and shared publicly as part of my professional portfolio for software development and algorithmic trading roles.

# Key Components
## 1. Strategy Manager Framework
 - A central Strategy Manager EA responsible for orchestrating strategy & simulation execution
 - Strategies are modular and loaded via #include based on configurable inputs
 - Designed to support:
     - Multiple strategy implementations
     - Consistent execution
     - Clear separation between strategy logic and simulation implementation

## 2. Individual Trading Strategies
 - Individual trading strategies implemented as modular components
 - Designed to be plug-and-play within the Strategy Manager
 - Focus on rule-based, testable logic, rather than discretionary and subjective systems

## 3. Prop-Firm Simulations
 - Framework for implementing prop firm challenge and funded account rules to any strategy
 - Works together with the Strategy Manager and uses account information to manage the simulations
 - Generates a csv report after each run to then process custom statistics using the SimulationManager.py

## 4. Research & Development (R&D)
 - Dedicated R&D files used to:
      - Validate simulations and research before deployment
      - Stress-test assumptions and ideas
      - Analyse behavious under different market conditions

## 5. Backtesting & Reports
 - Historical backtesting used to:
      - Validate strategy logic and value
      - Measure expectancy, drawdowns and risk-adjusted performance
 - Backtest reports for developed and validated strategy are included when relevant
 - Emphasis on robustness, instead of overfitting to historical data

# Design Philosophy
 - Modularity first - strategies, managers and utilities are decoupled
 - Reusability - shared components are designed with live trading and prop firm rules in mind
 - Engineering - code readibility and structured changes
 - Research driven development - strategies are validated through testing and simulations

This is a framework intended to support systematic strategy development and evaluation, both for brokerage usage or prop-firm environments.
