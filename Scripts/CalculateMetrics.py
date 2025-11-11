import pandas as pd
import numpy as np
from pathlib import Path
import os 
import csv

# ==========================
# CONFIGURATION 
# ==========================

#Automatically find MT5 Common Folder
commonFolder = Path(os.getenv("APPDATA")) / "MetaQuotes" / "Terminal" / "Common" / "Files" / "SimulationData"
testFolder = "MiddleRange_USDJPY_2025-11-10_19;24;15"
#subfolder = input("Specify the folder of the simulation reports: ")
fullPath = commonFolder / testFolder

#Define expected CSV files per phase type
phaseFiles = {
    "PHASE1": ["PHASE1.csv"],
    "PHASE2": ["PHASE2.csv"],
    "PHASE3": ["PHASE3.csv"],
    "CHALLENGE": ["CHALLENGE.csv"],
    "FUNDED": ["FUNDED.csv"],
}

# ==========================
# HELPER FUNCTIONS
# ==========================

def readCSV(filePath):
    if filePath.exists():
        df = pd.read_csv(filePath, encoding='utf-16', sep='\t')
        df.columns = df.columns.str.replace('\ufeff', '').str.strip()
        return df
    else:
        print(f"File not found: {filePath}")
        return None
    

# ==========================
# METRICS FUNCTIONS
# ==========================

def CalculatePhaseMetrics(df):
    df["Duration"] = df["Duration"].astype(float)
    outcomeSeries = df["Outcome"]

    # Metrics for phase 1 and phase 2
    totalPassed = (outcomeSeries == "Passed").sum()
    totalFailed = (outcomeSeries == "Failed").sum()
    totalOutcomes = totalPassed + totalFailed
    winrate = round((totalPassed / totalOutcomes) * 100, 2) if totalOutcomes else 0
    averageDuration = round(df["Duration"].astype(float).mean(), 2) if totalOutcomes else 0
    averagePassedDuration = round(df[df["Outcome"]=="Passed"]["Duration"].mean(), 2)
    averageFailedDuration = round(df[df["Outcome"]=="Failed"]["Duration"].mean(), 2)

    #Consecutive wins/losses
    passedGroups = (outcomeSeries == "Passed").astype(int).groupby((outcomeSeries != outcomeSeries.shift()).cumsum()).sum()
    failedGroups = (outcomeSeries == "Failed").astype(int).groupby((outcomeSeries != outcomeSeries.shift()).cumsum()).sum()
    maxConsWins = passedGroups.max()
    maxConsLosses = failedGroups.max()
    averageConsWins = round(passedGroups.mean(), 2)
    averageConsLosses = round(failedGroups.mean(), 2)

    return{
        "Total Passed": totalPassed,
        "Total Failed": totalFailed,
        "Winrate (%)": winrate,
        "Average Duration": averageDuration,
        "Average Duration When Passed": averagePassedDuration,
        "Average Duration When Failed": averageFailedDuration,
        "Max Consecutive Wins": maxConsWins,
        "Max Consecutive Losses": maxConsLosses,
        "Average Consecutive Wins": averageConsWins,
        "Average Consecutive Losses": averageConsLosses
    }

def CalculatePayoutMetrics(df):
    df["Duration"] = df["Duration"].astype(float)
    df["Start Balance"] = df["Start Balance"].astype(float)
    df["Ending Balance"] = df["Ending Balance"].astype(float)
    outcomeSeries = df["Outcome"]

    #Basic Metrics
    totalPassed = (outcomeSeries == "Payout").sum()
    totalFailed = (outcomeSeries == "Failed").sum()
    totalOutcomes = totalPassed + totalFailed
    winrate = round((totalPassed / totalOutcomes) * 100, 2) if totalOutcomes else 0
    averageDuration = round(df["Duration"].astype(float).mean(), 2) if totalOutcomes else 0
    averagePassedDuration = round(df[df["Outcome"]=="Payout"]["Duration"].mean(), 2)
    averageFailedDuration = round(df[df["Outcome"]=="Failed"]["Duration"].mean(), 2)

    #Consecutive Wins/Losses
    passedGroups = (outcomeSeries == "Payout").astype(int).groupby((outcomeSeries != outcomeSeries.shift()).cumsum()).sum()
    failedGroups = (outcomeSeries == "Failed").astype(int).groupby((outcomeSeries != outcomeSeries.shift()).cumsum()).sum()
    maxConsWins = passedGroups.max()
    maxConsLosses = failedGroups.max()
    averageConsWins = round(passedGroups.mean(), 2)
    averageConsLosses = round(failedGroups.mean(), 2)

    #Payout Metrics
    payoutRows = df[df["Outcome"] == "Payout"].copy()
    payoutRows["Payout Amount"] = payoutRows["Ending Balance"] - payoutRows["Start Balance"]
    averagePayout = round(payoutRows["Payout Amount"].mean(), 2) if not payoutRows.empty else 0
    totalPayoutAmmount = round(payoutRows["Payout Amount"].sum(), 2) if not payoutRows.empty else 0
    grossLoss = totalFailed * 80 #each fail attempt costs 80$ (10k account on 5ers)
    profitFactor = round(totalPayoutAmmount / grossLoss, 2) if grossLoss != 0 else float('inf')

    return{
        "Total Payouts": totalPassed,
        "Total Failed": totalFailed,
        "Winrate (%)": winrate,
        "Average Duration": averageDuration,
        "Average Duration When Payout": averagePassedDuration,
        "Average Duration When Failed": averageFailedDuration,
        "Max Consecutive Payouts": maxConsWins,
        "Max Consecutive Losses": maxConsLosses,
        "Average Consecutive Payouts": averageConsWins,
        "Average Consecutive Losses": averageConsLosses,
        "Average Payout($)": averagePayout,
        "Total Payouts ($)": totalPayoutAmmount,
        "Total Failed Cost ($)": grossLoss,
        "Profit Factor": profitFactor
    }

def CalculateChallengeMetrics(df):
    df = df.copy()
    df["Outcome"] = df["Outcome"].astype(str).str.strip()
    df["Phase"] = pd.to_numeric(df["Phase"], errors = "coerce").fillna(0).astype(int)
    df["Duration"] = pd.to_numeric(df["Duration"], errors = "coerce").fillna(0)

    #Group by challenge number
    challengeGroups = df.groupby("Challenge Number")
    totalChallenges = challengeGroups.ngroups
    totalWonChallenges = 0
    totalFailedChallenges = 0
    
    #Store durations for passed/failed challenges
    challengeDurations = []
    passedDurations = []
    failedDurations = []
    challengeOutcomes = []

    #Count failures by phase
    failedPhase1Count = 0
    failedPhase2Count = 0

    for challengeNum, group in challengeGroups:
        p1 = group[group["Phase"] == 1]
        p2 = group[group["Phase"] == 2]
        totalDuration = group["Duration"].sum()

        if not p1.empty and not p2.empty:
            if(p1["Outcome"].iloc[0] == "Passed") and (p2["Outcome"].iloc[0] == "Passed"):
                totalWonChallenges +=1
                passedDurations.append(totalDuration)
                challengeOutcomes.append("Passed")
            else:
                totalFailedChallenges += 1
                failedDurations.append(totalDuration)
                challengeOutcomes.append("Failed")

                #Count which phase failed
                if p1["Outcome"].iloc[0] == "Failed":
                    failedPhase1Count += 1
                elif p2["Outcome"].iloc[0] == "Failed":
                    failedPhase2Count += 1
        else:
            totalFailedChallenges += 1
            failedDurations.append(totalDuration)
            challengeOutcomes.append("Failed")
            failedPhase1Count += 1
        
        challengeDurations.append(totalDuration)
    
    # BASIC STATISTICS / METRICS
    winrate = round((totalWonChallenges / totalChallenges) * 100, 2) if totalChallenges else 0
    averageDurationTotal = round(sum(challengeDurations) / len(challengeDurations), 2) if challengeDurations else 0
    averageDurationPassed = round(sum(passedDurations) / len(passedDurations), 2) if passedDurations else 0
    averageDurationFailed = round(sum(failedDurations) / len(failedDurations), 2) if failedDurations else 0

    # CONSECUTIVE WINS & LOSSES
    if challengeOutcomes:
        series = pd.Series(challengeOutcomes)
        groups = (series != series.shift()).cumsum()
        streaks = series.groupby(groups).agg(['first', 'size'])

        winStreaks = streaks[streaks['first'] == 'Passed']["size"]
        lossStreaks = streaks[streaks['first'] == 'Failed']["size"]

        maxConsecutiveWins = int(winStreaks.max()) if not winStreaks.empty else 0
        maxConsecutiveLosses = int(lossStreaks.max()) if not lossStreaks.empty else 0
        averageConsecutiveWins = round(winStreaks.mean(), 2) if not winStreaks.empty else 0
        averageConsecutiveLosses = round(winStreaks.mean(), 2) if not lossStreaks.empty else 0
    else:
        maxConsecutiveWins = maxConsecutiveLosses = averageConsecutiveWins = averageConsecutiveLosses = 0
    
    # FAIL % PER PHASE
    failedPhase1Percentage = round((failedPhase1Count / totalFailedChallenges) * 100, 2) if totalFailedChallenges else 0
    failedPhase2Percentage = round((failedPhase2Count / totalFailedChallenges) * 100, 2) if totalFailedChallenges else 0

    return {
        "Total Challenges": totalChallenges,
        "Won Challenges": totalWonChallenges,
        "Winrate (%)": winrate,
        "Average Duration Total": averageDurationTotal,
        "Average Duration Passed": averageDurationPassed,
        "Average Duration Failed": averageDurationFailed,
        "Max Consecutive Wins": maxConsecutiveWins,
        "Max Consecutive Losses": maxConsecutiveLosses,
        "Average Consecutive Wins": averageConsecutiveWins,
        "Average Consecutive Losses": averageConsecutiveLosses,
        "% Failed Phase 1": failedPhase1Percentage,
        "% Failed Phase 2": failedPhase2Percentage
    }

def CalculateFundedMetrics(df):
    df = df.copy()
    df["Outcome"] = df["Outcome"].astype(str).str.strip()
    df["Phase"] = pd.to_numeric(df["Phase"], errors="coerce").fillna(0).astype(int)
    df["Duration"] = pd.to_numeric(df["Duration"], errors="coerce").fillna(0)
    df["Start Balance"] = pd.to_numeric(df["Start Balance"], errors="coerce").fillna(0)
    df["Ending Balance"] = pd.to_numeric(df["Ending Balance"], errors="coerce").fillna(0)

    challengeGroups = df.groupby("Challenge Number")
    totalChallenges = challengeGroups.ngroups
    challengeWins = 0
    totalPayouts = 0
    totalFailedChallenges = 0

    challengeDurations = []
    passedDurations = []
    failedDurations = []
    challengeOutcomes = []
    payoutProfits = []
    allChallengePayoutStreaks = []

    for challengeNum, group in challengeGroups:
        payouts = group[group["Outcome"] == "Payout"]
        failed = group[group["Outcome"] == "Failed"]
        totalDuration = group["Duration"].sum()
        challengeDurations.append(totalDuration)

        # Track challenge-level win/fail
        if not payouts.empty:
            challengeWins += 1
            totalPayouts += len(payouts)
            passedDurations.append(totalDuration)
            challengeOutcomes.append("Payout")
            profits = (payouts["Ending Balance"] - payouts["Start Balance"]).tolist()
            payoutProfits.extend(profits)

        if not failed.empty and payouts.empty:
            totalFailedChallenges += 1
            failedDurations.append(totalDuration)
            challengeOutcomes.append("Failed")

        # --- Consecutive payouts within this challenge ---
        if not group.empty:
            outcome_series = (group["Outcome"] == "Payout").astype(int)
            streak_groups = (outcome_series != outcome_series.shift()).cumsum()
            streaks = outcome_series.groupby(streak_groups).sum()
            if not streaks.empty:
                allChallengePayoutStreaks.extend(streaks[streaks > 0].tolist())

    # BASIC METRICS / STATISTIC
    challengeWinrate = round((challengeWins / totalChallenges) * 100, 2) if totalChallenges else 0
    payoutWinrate = round((totalPayouts / (totalPayouts + totalFailedChallenges)) * 100, 2) if (totalPayouts + totalFailedChallenges) else 0
    averageDurationTotal = round(sum(challengeDurations) / len(challengeDurations), 2) if challengeDurations else 0
    averageDurationPassed = round(sum(passedDurations) / len(passedDurations), 2) if passedDurations else 0
    averageDurationFailed = round(sum(failedDurations) / len(failedDurations), 2) if failedDurations else 0

    # CONSECUTIVE WINS & LOSSES
    if challengeOutcomes:
        series = pd.Series(challengeOutcomes)
        groups = (series != series.shift()).cumsum()
        streaks = series.groupby(groups).agg(['first', 'size'])

        winStreaks = streaks[streaks['first'] == 'Payout']["size"]
        lossStreaks = streaks[streaks['first'] == 'Failed']["size"]

        maxConsecutiveWins = int(winStreaks.max()) if not winStreaks.empty else 0
        maxConsecutiveLosses = int(lossStreaks.max()) if not lossStreaks.empty else 0
        averageConsecutiveWins = round(winStreaks.mean(), 2) if not winStreaks.empty else 0
        averageConsecutiveLosses = round(lossStreaks.mean(), 2) if not lossStreaks.empty else 0
    else:
        maxConsecutiveWins = maxConsecutiveLosses = averageConsecutiveWins = averageConsecutiveLosses = 0

    maxConsecutivePayoutsPerChallenge = max(allChallengePayoutStreaks) if allChallengePayoutStreaks else 0
    averageConsecutivePayoutsPerChallenge = round(sum(allChallengePayoutStreaks) / len(allChallengePayoutStreaks), 2) if allChallengePayoutStreaks else 0

    # PROFIT METRICS
    averageProfitPerPayout = round(sum(payoutProfits) / len(payoutProfits), 2) if payoutProfits else 0
    totalChallengeProfits = []
    for challengeNum, group in challengeGroups:
        payouts = group[group["Outcome"] == "Payout"]
        if not payouts.empty:
            totalProfit = (payouts["Ending Balance"] - payouts["Start Balance"]).sum()
        else:
            totalProfit = 0  # failed challenges
        totalChallengeProfits.append(totalProfit)
    
    averageTotalProfitPerChallenge = round(sum(totalChallengeProfits) / len(totalChallengeProfits), 2) if totalChallengeProfits else 0

    # MONTHLY METRICS / STATISTICS (fixed version)
    df["End Phase Date"] = pd.to_datetime(df["End Phase Date"], errors="coerce")
    df["PnL"] = np.where(
        df["Outcome"] == "Payout",
        df["Ending Balance"] - df["Start Balance"],
        np.where(df["Outcome"] == "Failed", -80, 0)
    )

    df["Month"] = df["End Phase Date"].dt.to_period("M").astype(str)
    monthlyPnL = df.groupby("Month")["PnL"].sum()
    winningMonths = int((monthlyPnL > 0).sum())
    losingMonths = int((monthlyPnL <= 0).sum())
    monthlyWinrate = round((winningMonths / (winningMonths + losingMonths)) * 100, 2) if (winningMonths + losingMonths) else 0
    averageMonthlyProfit = round(monthlyPnL[monthlyPnL > 0].mean(), 2) if (monthlyPnL > 0).any() else 0
    averageMonthlyLoss = round(monthlyPnL[monthlyPnL <= 0].mean(), 2) if (monthlyPnL <= 0).any() else 0
    monthlyWinLossRatio = round(winningMonths / losingMonths, 2) if losingMonths > 0 else float('inf')
    
    df["PnL"] = df["PnL"].round(2)
    df["Monthly Profit"] = df["Month"].map(monthlyPnL).round(2)
    monthlyDF = df[["Challenge Number", "Phase", "Start Phase Date", "End Phase Date", "Outcome", "PnL", "Monthly Profit"]]
    csvFile = fullPath / "MONTHLY_FUNDED.csv"
    monthlyDF.to_csv(csvFile, index=False, encoding='utf-16', sep='\t')

    return {
        "Challenge Winrate": challengeWinrate,
        "Payout Winrate": payoutWinrate,
        "Average Duration Total": averageDurationTotal,
        "Average Duration Passed": averageDurationPassed,
        "Average Duration Failed": averageDurationFailed,
        "Max Consecutive Wins (Challenges)": maxConsecutiveWins,
        "Max Consecutive Losses (Challenges)": maxConsecutiveLosses,
        "Average Consecutive Wins (Challenges)": averageConsecutiveWins,
        "Average Consecutive Losses (Challenges)": averageConsecutiveLosses,
        "Max Consecutive Payouts": maxConsecutivePayoutsPerChallenge,
        "Average Payouts Per Challenge": averageConsecutivePayoutsPerChallenge,
        "Average Profit Per Payout ($)": averageProfitPerPayout,
        "Average Profit Per Challenge": averageTotalProfitPerChallenge,
        "Winning Months": winningMonths,
        "Loosing Months": losingMonths,
        "Monthly Winrate": monthlyWinrate,
        "Average Monthly Profit": averageMonthlyProfit,
        "Average Monthly Loss": averageMonthlyLoss,
        "Monthly W/L Ratio": monthlyWinLossRatio
    }

#Map phase type to function
metricFunctions = {
    "PHASE1": CalculatePhaseMetrics,
    "PHASE2": CalculatePhaseMetrics,
    "PHASE3": CalculatePayoutMetrics,
    "CHALLENGE": CalculateChallengeMetrics,
    "FUNDED": CalculateFundedMetrics
}

# =======================
# PROCESS CSV FILES
# =======================

groupedMetrics = {
    "PHASE1&2": {},
    "PHASE3": {},
    "CHALLENGE": {},
    "FUNDED": {}
}

for phaseType, files in phaseFiles.items():
    for fileName in files:
        filePath = fullPath / fileName
        df = readCSV(filePath)
        if df is not None:
            metrics = metricFunctions[phaseType](df)

            #Assign metrics to correct group
            if phaseType in ["PHASE1", "PHASE2"]:
                groupedMetrics["PHASE1&2"][fileName.replace(".csv", "")] = metrics
            elif phaseType == "PHASE3":
                groupedMetrics["PHASE3"][fileName.replace(".csv", "")] = metrics
            elif phaseType == "CHALLENGE":
                groupedMetrics["CHALLENGE"][fileName.replace(".csv", "")] = metrics
            elif phaseType == "FUNDED":
                groupedMetrics["FUNDED"][fileName.replace(".csv", "")] = metrics

# =======================
# SAVE METRICS TO CSV FILE
# =======================

#Create  metrics folder if it doesnt exist
metricsFolder = fullPath / "METRICS"
metricsFolder.mkdir(exist_ok=True)

def SaveMetrics(groupsName, metricsDict):
    if not metricsDict:
        print(f"No metrics found for {groupsName}")
        return
    
    filePath = metricsFolder / f"METRICS_{groupsName}.csv"
    with open(filePath, mode="w", newline='', encoding='utf-16') as f:
        writer = csv.writer(f, delimiter='\t')
        headers = ["Phase"] + list(next(iter(metricsDict.values())).keys())
        writer.writerow(headers)
        for phase, metrics in metricsDict.items():
            row = [phase] + list(metrics.values())
            writer.writerow(row)

print(f"Metrics saved to {filePath}")

#SAVE EACH GROUP
SaveMetrics("PHASE1&2", groupedMetrics["PHASE1&2"])
SaveMetrics("PHASE3", groupedMetrics["PHASE3"])
SaveMetrics("CHALLENGE", groupedMetrics["CHALLENGE"])
SaveMetrics("FUNDED", groupedMetrics["FUNDED"])