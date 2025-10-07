# Risk Management Tests

All the tests regarding risk management on personal, brokerage trading accounts.

## Tests Done

Each test contains reports, graphs and the .mq5 file used to run the tests.

### Highest Balance Compounding

    - Only compounds on new equity highs.

### Highest Balance Compounding + Static Risk Comparison

    - Only compounds on new equity highs.
    - Different base risks were tested.
    - Only from 2015-2018 due to compounding having too much of an effect on the graph and metrics after a few years.

### Risk Multiplier Martingale

    - Uses martingale (1.5x on 1:2rr) but tested the multiplier.

### Static Risk Comparison

    - Just changes the base risk per trade to see how much risk is too much and how much is too little.

### Other Files

    - Base strategy reports used on the tests (1% risk per trade)
    - NC = No Compounding
    - WC = With Compounding
    - MQ5 File of strategy used
