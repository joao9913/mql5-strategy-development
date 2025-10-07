# MA Crossover

Uses two moving averages. The ma's can't touch eachother for a certain number of candles. Enters on the crossover of these mas, in the direction of the cross.

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
