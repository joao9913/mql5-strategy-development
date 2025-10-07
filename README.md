# MQL5 Repository

## Overview

This repository contains all MetaTrader 5 development work, including Expert Advisors, include files, presets, and optimization data for trading systems developed under Vantedge Trading.

The goal is to maintain a complete version-controlled record of all active and experimental projects, with clear separation between strategies, risk management systems, and shared code modules.

## Structure

- ## Experts/

  - ## Trading Strategies/
    - ## In Development
      - Notes.md
    - ## Strategy Manager
      - Notes.md

- ## Risk Management/
  - ## Prop Firm Trading/
    - Notes.md
    - ## In Development
      - Notes.md
    - ## Strategy Manager
      - Notes.md
  - ## Personal Account Trading/
    - ## In Development
      - ## Risk Management Tests
        - ## Highest Balance Compounding
        - ## Highest Balance Compounding + Static Risk Comparison
        - ## Risk Multiplier Martingale
        - ## Static Risk Comparison
        - Base Report NC.html
        - Base Report NC.png
        - Base Report WC.html
        - Base Report WC.png
        - Notes.md

## Versioning Guidelines

    Each EA or include file should have its version noted in both the filename and header comment.
    When making major changes:
    Create a new version file (e.g., PushMethod_v1.3.mq5)
    Update the changelog under /Docs/
    Commit with a descriptive message:
    git commit -m "PushMethod v1.3 - Added dynamic breakeven and updated scaling logic"

## How To Use

    Clone this repository into your MetaTrader 5 MQL5 directory.
    Ensure your .gitignore excludes unnecessary MT5 folders (Tester, Logs, etc.).
    Update and commit changes only to:
    /Experts/Vantedge/
    /Include/Vantedge/
    /Presets/
    /Optimizations/
    Push to GitHub regularly to keep version history synced.

## Resources
