# OffsetMA.mqh

Trades based on a moving average upper and lower offset

## Entry Criteria

    - Calculates positive and negative offset from moving average
    - Enters long when price touches the negative offset
    - Enters short when price touches the positive offset

## Stop-Loss

    - If long, below the offset ma using an atr multiplier
    - if short, above the offset ma using the atr multiplier

## Take-Profit

    - 1:2 Risk-To-Reward Ratio

## Input Variables

    - MAPeriod          - Period of the moving average                                - 10 - 10 - 200
    - OffsetPercentage  - How much in % the offsets are away from the moving average  - 1 - 1 - 25
    - ATRMultiplier     - How much to multiply the atr for the stop loss              - Same as previous strategies

## Pairs/Markets

    - To Be Optimized

## Visual Mode Objects

    - Normal MA
    - Positive & Negative Offset
    - Visual Confirmation Of Retest
