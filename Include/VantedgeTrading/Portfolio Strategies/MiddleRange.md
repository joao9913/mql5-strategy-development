# MiddleRange.mqh

Identifies a range and trades according to its middle

## Entry Criteria

    - Waits for entry hour and minute
    - Draws range from highest high to lowest low of certain number of candles
    - Calculates the middle of this range
    - Enters Long if price closed above the middle line at entry hour
    - Enters Short if price closed below the middle line at entry hour

## Stop-Loss

    - If long, on the low of the range
    - If short, on the high of the range

## Take-Profit

    - 1:2 Risk-To-Reward Ratio

## Input Variables

    - RangeBars         - How many candles to draw the range
    - EntryHour         - Which hour to draw the range
    - EntryMinute       - Which minute to draw the range

## Pairs/Markets

    - USDJPY

## Visual Mode Objects

    - Range (Start Date, End Date, High, Low)
    - Middle Line
    - Entry Hour Line
