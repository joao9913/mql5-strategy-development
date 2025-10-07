# Trading Strategies

All include files for each individual finished strategy

## Strategy.mqh

Contains methods & variables that most strategies use, and some that every strategy needs to use

### CalculateLots()

    Calculates lots depending on account balance and risk, adjusted per pair

### CheckOpenOrders()

    Check if there are any open pending orders

### CheckOpenTrades()

    Check if there are any open active trades

### GetCurrentMinute()

    Get current minute from currentTime()

### GetCurrentHour()

    Get current hour from currentTime()

### ResetControlVariables()

    Reset control variables if no trades/orders are open before the next trading day

### CancelOpenOrders()

    Cancel all open pending orders

## HourBreakout.mqh

    - Waits for entry hour
    - Draws range from highest high to lowest low, from entry hour to lookback bars
    - Enters two pendings on each side of the range
    - Stop loss on the opposite side of the range
    - When one trade is activated, cancels opposite order

### Pairs/Markets

    - USDJPY
    - GBPUSD

## MiddleRange.mqh

    - Waits for entry hour & entry minute
    - Draws range from highest high to lowest low, from entry hour to lookback bars
    - Enters long if price closed above the middle
    - Enters short if price closed below the middle
    - Stop loss on the opposite side of the range

### Pairs/Markets

    - USDJPY
