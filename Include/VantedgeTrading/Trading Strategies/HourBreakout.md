# HourBreakout.mqh

Calculates a range of candles from high to low, enters when price breaks out of one of these extremes

## Entry Criteria

    - Waits for entry hour & minute
    - Draws a range from highest high to lowest low of n number of candles
    - Enters a buy stop and a sell stop order at the high and low of the range
    - Cancels the opposite order once one is triggered

## Stop-Loss

    - If long, at the low of the range
    - If short, at the high of the range

## Take-Profit

    - 1:2 Risk-To-Reward Ratio

## Input Variables

    - RangeBars     - How many candles to define the range
    - EntryHour     - At which hour to draw the range

## Pairs/Markets

    - USDJPY
    - GBPUSD
