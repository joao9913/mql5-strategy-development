# SwingReversal.mqh

Takes advantage of extreme swing points from untested highs and lows

## Entry Criteria

    - Calculates previous extreme high and low points
    - Checks if nearby candles dont pass these points
    - Creates area around these points with atr multiplier
    - Enter when price retests these areas
    - If a new area is created, expire previous ones

## Stop-Loss

    - If long, on the low of the area created
    - if short, on the high of the area created

## Take-Profit

    - 1:2 Risk-To-Reward Ratio

## Input Variables

    - NeighbourCandles  - Number of candles to use for verification of swing point 
    - ATRMultiplier     - How much to multiply the area around the swing point

## Pairs/Markets

    - To Be Optimized
