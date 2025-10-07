# MA Retest

Uses a single MA. Price needs to be above/below the MA for a certain number of candles, enters on the retest, stop-loss with the atr.

## Entry Criteria

    - Needs to close above/below the MA
    - Needs to be above/below the MA for a certain number of candles
    - Needs to touch the MA to enter a trade

## Stop-Loss

    - If long, below the MA
    - If short, above the MA
    - Uses atr multiplier to place the stop loss

## Take-Profit

    - 1:2 Risk-To-Reward Ratio
