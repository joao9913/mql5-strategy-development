# Strategy.mqh

Contains methods & variables that most strategies use, and some that every strategy needs to use

## CalculateLots()

    Calculates lots depending on account balance and risk, adjusted per pair

## IsNewCandle()
    
    Checks if its a new candle. Used to optimize EAs

## CheckOpenOrders()

    Check if there are any open pending orders

## CheckOpenTrades()

    Check if there are any open active trades

## GetCurrentMinute()

    Get current minute from currentTime()

## GetCurrentHour()

    Get current hour from currentTime()

## ResetControlVariables()

    Reset control variables if no trades/orders are open before the next trading day

## CancelOpenOrders()

    Cancel all open pending orders
