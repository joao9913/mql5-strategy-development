# MARetest.mqh

Uses a Moving Average to identify direction and enters when price retests this MA.

## Entry Criteria

    - Price needs to be above or below the MA for a certain number of candles (lookback)
    - Waits for price to touch the MA
    - Enters on the retest

## Stop-Loss

    - If long, below the MA
    - If short, above the MA
    - Uses atr multiplier to place the stop loss

## Take-Profit

    - 1:2 Risk-To-Reward Ratio

## Input Variables

    - MAPeriod      - Period that the MA uses
    - Lookback      - How many candles should price be above/below the MA
    - ATRMultiplier - Stoploss ATR Multiplier

## Pairs/Markets

    - To Be Optimized
