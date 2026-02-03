# Prop Firm Tracker

This module is designed to manage live prop firm trading accounts and ensure risk and drawdown limits are enforced in real time. It allows traders to:
    - Track account equity and performance for live strategies
    - Enforce phase-specific targets
    - Apply risk division across multiple strategies
    - Prevent violations of max drawdown and daily drawdown limits
    - Automatically disable trading when account conditions are breached
It is primarily used alongside the Portfolio Manager EA, ensuring live accounts remain within prop firm constraints while trading multiple strategies.

# Key Features
    - Phase-Based account management - supports challenge, verification, funded and manual modes with configurable profit targets and risk levels
    - Real time drawdown monitoring - tracks total drawdown and daily drawdown, automatically stopping trading if limits are exceeded
    - Risk allocation across strategies - Divides total account risk evenly across all active strategies to prevent overexposure
    - Automated trade management - closes all open positions when account constraints are breached and stops further trading until reset
    - Account status tracking - provides a detailed on-chart comment showing information regarding the account

# Skills
This module showcases:
  - MQL5 Expertise: classes, inheritance, modular EAs
  - Real-time drawdown calculation and automated control
  - Phase based account management for prop firm challenges
  - Modular design suitable for integration with multiple strategies
  - On-chart reporting for trader visibility