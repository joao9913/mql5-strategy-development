# Simulation Metrics

## Overview

    List and grouping of metrics that define a prop firm simulation. Everything regarding Phase1, Phase2, Phase2, Challenge & Funded simulations.

## Phase 1 & 2

    - Nº Challenges                         - How many challenges were simulated
    - Nº Passed                             - How many challenges were passed
    - Nº Failed                             - How many challenges were failed
    - Winrate                               - Winrate of passed challenges
    - Average Duration                      - Average duration of total challenges (passed or failed)
    - Average Duration Passed               - Average duration of passed challenges only
    - Average Duration Failed               - Average duration of failed challenges only
    - Max Consecutive Wins                  - How many maximum consecutive passed challenges
    - Max Consecutive Losses                - How many maximum consecutive failed challenges
    - Average Consecutive Wins              - Average consecutive passed challenges
    - Average Consecutive Losses            - Average consecutive failed challenges
    - Efficiency Ratio                      - Efficiency ratio of challenges winrate and duration (winrate / duration)

## Phase 3

    - Nº Challenges                         - How many challenges were simulated
    - Nº Payouts                            - How many payouts were obtained
    - Nº Failed                             - How many challenges were failed
    - Winrate                               - Winrate of passed challenges
    - Average Duration                      - Average duration of total challenges (passed or failed)
    - Average Duration Passed               - Average duration of passed challenges only
    - Average Duration Failed               - Average duration of failed challenges only
    - Max Consecutive Payouts               - How many maximum consecutive passed challenges
    - Max Consecutive Losses                - How many maximum consecutive failed challenges
    - Average Consecutive Payouts           - Average consecutive passed challenges
    - Average Consecutive Losses            - Average consecutive failed challenges
    - Average Payout ($)                    - How much in average is a payout profit (in dollars)
    - Total Payouts ($)                     - How much total payout profits (in dollars)
    - Total Failed ($)                      - How much total failed challenges lost (in dollars)
    - Profit Factor                         - Ratio between total payout profit and total loss (total payouts ($)/ total failed ($))
    - Profitability Ratio                   - Ratio of profitability of this phase ((winrate / 100) * average payout profit)

## Challenge

    - Nº Challenges                         - How many challenges were simulated
    - Nº Passed                             - How many challenges were passed
    - Nº Failed                             - How many challenges were failed
    - Winrate                               - Winrate of passed challenges
    - Average Duration                      - Average duration of total challenges (passed or failed)
    - Average Duration Passed               - Average duration of passed challenges only
    - Average Duration Failed               - Average duration of failed challenges only
    - Max Consecutive Wins                  - How many maximum consecutive passed challenges
    - Max Consecutive Losses                - How many maximum consecutive failed challenges
    - Average Consecutive Wins              - Average consecutive passed challenges
    - Average Consecutive Losses            - Average consecutive failed challenges
    - Failed Phase 1 (%)                    - From failed challenges, how much were failed in Phase 1
    - Failed Phase 2 (%)                    - From failed challenges, how much were failed in Phase 2
    - Efficiency Ratio                      - Efficiency ratio between winrate and average duration of challenges

## Funded

### Challenge

    - Nº Challenges                         - How many challenges were simulated
    - Nº Passed                             - How many challenges were passed with at least one payout
    - Nº Failed                             - How many challenges failed before getting at least one payout
    - Winrate                               - Winrate between passed and failed challenges
    - Average Duration                      - Average duration of total challenges (passed or failed)
    - Average Duration Passed               - Average duration of passed challenges only
    - Average Duration Failed               - Average duration of failed challenges only
    - Max Consecutive Wins                  - How many maximum consecutive passed challenges
    - Max Consecutive Failed                - How many maximum consecutive failed challenges
    - Average Consecutive Wins              - Average consecutive passed challenges
    - Average Consecutive Losses            - Average consecutive failed challenges
    - Average Profit Per Challenge          - Average profit per challenge (total passed challenge profits / total number of passed challenges)
    - Challenge Efficiency Ratio            - Measures profit per challenge adjusted for failure rate (Average profit per challenge / number of failed challenges)

### Payouts

    - Nº Payouts                            - How many total payouts were obtained
    - Payout Winrate                        - Winrate between payout outcomes and failed challenges
    - Max Consecutive Payouts               - How many maximum consecutive payouts
    - Average Payouts Per Challenge         - How many average payouts per challenge
    - Average Profit Per Payout             - How much profit per payout in average (in dollars)
    - Profitability Ratio                   - Ratio between payout winrate, average payouts per challenge and average profit per payout ((payout winrate / 100) * average payouts per challenge * average profit per payout)

### Monthly

    - Winning Months                        - How many total months finished in profit
    - Losing Months                         - How many total months finished in loss
    - Monthly Winrate                       - Winrate between won and lost months
    . Average Monthly PnL                   - Average monthly profit (either passed or failed)
    - Average Monthly Profit                - Average monthly profit (only won months)
    - Average Monthly Loss                  - Average monthly loss (only lost months)
    - Max Consecutive Winning Months        - Max consecutive months that were won
    - Max Consecutive Losing Months         - Max consecutive months that were lost
    - Average Consecutive Winning Months    - Average consecutive won months
    - Average Consecutive Losing Months     - Average consecutive lost months
    - Monthly Win/Loss Ratio                - Ratio between winning months and losing months (winning months / losing months)
    - Monthly Stability & Return Ratio      - Consistency and profitability ratio (((monthly winrate / 100) * average monthly profit) / (average monthly loss * -1))
    - Overall Risk-Adjusted Returns         - Ratio of both challenge efficiency and monthly stability (challenge efficiency ratio * monthly stability & return ratio)
