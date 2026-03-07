# DynamicRangeBreakout.mqh

Draws a range every new candle, compares with ATR and if < than threshold, enters on the breakout

## Entry Criteria

    - Draws a range from highest high to lowest low of n number of candles every candle
    - Compares range with atr using atr multiplier
    - If less than atr, waits for a breakout
    - Enters on the breakout

## Stop-Loss

    - If long, at the low of the range
    - If short, at the high of the range

## Take-Profit

    - 1:2 Risk-To-Reward Ratio

## Input Variables

    - RangeBars     - How many candles to define the range
    - ATRPeriod     - How many candles to use for the ATR
    - ATRMultiplier - How much the atr needs to be bigger than the range

## Pairs/Markets

    - To Be Tested

## Visual Mode Objects

    - Range (Start Date, End Date, High, Low)
