# MACrossover.mqh

Uses two moving averages to identify a crossover between them.

## Entry Criteria

    - Short MA needs to be below/above the Long MA for a certain number of candles
    - Waits for a crossover of the short MA over the long MA
    - Enters on the cross

## Stop-Loss

    - If long, below the MAs
    - If short, above the MAs
    - Uses atr multiplier to place the stop loss

## Take-Profit

    - 1:2 Risk-To-Reward Ratio

## Input Variables

    - ShortMAPeriod     - Shorter MA Period
    - LongMAPeriod      - Longer MA Period
    - Lookback          - How many candles does the short MA need to be above/below the long MA
    - ATRMultiplier     - Stoploss ATR Multiplier

## Pairs/Markets

    - To Be Optimized

## Visual Mode Objects

    - Short MA
    - Long MA
    - Visual Indicator Of Lookback Check
    - Visual Indicator Of Crossover
