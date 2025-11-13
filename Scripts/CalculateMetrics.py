import pandas as pd
import numpy as np
from pathlib import Path
import os 
import csv
import webbrowser

# ==========================
# CONFIGURATION 
# ==========================

#Automatically find MT5 Common Folder
commonFolder = Path(os.getenv("APPDATA")) / "MetaQuotes" / "Terminal" / "Common" / "Files" / "SimulationData"
#subfolder = "HourBreakout_USDJPY_2025-11-12_17;15;23"
subfolder = input("Specify the folder of the simulation reports: ")
fullPath = commonFolder / subfolder
metricsFolder = fullPath / "METRICS"
metricsFolder.mkdir(exist_ok=True)

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

def calculate_consecutive(series, outcome):
    # Create boolean series where True = desired outcome
    mask = series == outcome
    # Only keep streaks where outcome is True
    streaks = mask.groupby((mask != mask.shift()).cumsum()).sum()
    # Only keep streaks > 0
    streaks = streaks[streaks > 0]
    return streaks


def CalculatePhaseMetrics(df):
    df["Duration"] = df["Duration"].astype(float)
    outcomeSeries = df["Outcome"]

    totalPassed = (outcomeSeries == "Passed").sum()
    totalFailed = (outcomeSeries == "Failed").sum()
    totalOutcomes = totalPassed + totalFailed
    winrate = round((totalPassed / totalOutcomes) * 100, 2) if totalOutcomes else 0
    averageDuration = round(df["Duration"].mean(), 2) if totalOutcomes else 0
    averagePassedDuration = round(df[df["Outcome"]=="Passed"]["Duration"].mean(), 2)
    averageFailedDuration = round(df[df["Outcome"]=="Failed"]["Duration"].mean(), 2)

    # Consecutive wins/losses
    passedGroups = calculate_consecutive(outcomeSeries, "Passed")
    failedGroups = calculate_consecutive(outcomeSeries, "Failed")

    maxConsWins = passedGroups.max()
    maxConsLosses = failedGroups.max()
    averageConsWins = round(passedGroups.mean(), 2)
    averageConsLosses = round(failedGroups.mean(), 2)

    return {
        "Nº Passed": totalPassed,
        "Nº Failed": totalFailed,
        "Winrate (%)": winrate,
        "Avg Duration": averageDuration,
        "Avg Duration Passed": averagePassedDuration,
        "Avg Duration Failed": averageFailedDuration,
        "Max Cons Wins": maxConsWins,
        "Max Cons Losses": maxConsLosses,
        "Avg Cons Wins": averageConsWins,
        "Avg Cons Losses": averageConsLosses
    }

def CalculatePayoutMetrics(df):
    df["Duration"] = df["Duration"].astype(float)
    df["Start Balance"] = df["Start Balance"].astype(float)
    df["Ending Balance"] = df["Ending Balance"].astype(float)
    outcomeSeries = df["Outcome"]

    # Basic Metrics
    totalPassed = (outcomeSeries == "Payout").sum()
    totalFailed = (outcomeSeries == "Failed").sum()
    totalOutcomes = totalPassed + totalFailed
    winrate = round((totalPassed / totalOutcomes) * 100, 2) if totalOutcomes else 0
    averageDuration = round(df["Duration"].mean(), 2) if totalOutcomes else 0
    averagePassedDuration = round(df[df["Outcome"]=="Payout"]["Duration"].mean(), 2) if totalPassed else 0
    averageFailedDuration = round(df[df["Outcome"]=="Failed"]["Duration"].mean(), 2) if totalFailed else 0

    # Consecutive Wins/Losses
    passedGroups = calculate_consecutive(outcomeSeries, "Payout")
    failedGroups = calculate_consecutive(outcomeSeries, "Failed")
    maxConsWins = passedGroups.max() if not passedGroups.empty else 0
    maxConsLosses = failedGroups.max() if not failedGroups.empty else 0
    averageConsWins = round(passedGroups.mean(), 2) if not passedGroups.empty else 0
    averageConsLosses = round(failedGroups.mean(), 2) if not failedGroups.empty else 0

    # Payout Metrics
    payoutRows = df[df["Outcome"] == "Payout"].copy()
    payoutRows["Payout Amount"] = payoutRows["Ending Balance"] - payoutRows["Start Balance"]
    averagePayout = round(payoutRows["Payout Amount"].mean(), 2) if not payoutRows.empty else 0
    totalPayoutAmmount = round(payoutRows["Payout Amount"].sum(), 2) if not payoutRows.empty else 0
    grossLoss = totalFailed * 80  # each fail attempt costs $80
    profitFactor = round(totalPayoutAmmount / grossLoss, 2) if grossLoss != 0 else float('inf')

    return {
        "Nº Payouts": totalPassed,
        "Nº Failed": totalFailed,
        "Winrate (%)": winrate,
        "Avg Duration": averageDuration,
        "Avg Duration Payout": averagePassedDuration,
        "Avg Duration Failed": averageFailedDuration,
        "Max Cons Payouts": maxConsWins,
        "Max Cons Losses": maxConsLosses,
        "Avg Cons Payouts": averageConsWins,
        "Avg Cons Losses": averageConsLosses,
        "Avg Payout($)": averagePayout,
        "Total Payouts ($)": totalPayoutAmmount,
        "Total Failed ($)": grossLoss,
        "Profit Factor": profitFactor
    }

def CalculateChallengeMetrics(df):
    df = df.copy().reset_index(drop=False).rename(columns={"index": "_row_index"})
    df["Outcome"] = df["Outcome"].astype(str).str.strip()
    df["Phase"] = pd.to_numeric(df["Phase"], errors="coerce").fillna(0).astype(int)
    df["Duration"] = pd.to_numeric(df["Duration"], errors="coerce").fillna(0)

    # Group by strategy + challenge
    if "Strategy" in df.columns:
        challengeGroups = df.groupby(["Strategy", "Challenge Number"])
    else:
        challengeGroups = df.groupby("Challenge Number")

    challenge_records = []
    failedPhase1Count = failedPhase2Count = 0

    for (keys), group in challengeGroups:
        p1 = group[group["Phase"] == 1]
        p2 = group[group["Phase"] == 2]
        totalDuration = group["Duration"].sum()

        if not p2.empty:
            completion_row = p2["_row_index"].min()
        else:
            completion_row = p1["_row_index"].min() if not p1.empty else group["_row_index"].min()

        if (not p1.empty and not p2.empty
            and p1["Outcome"].iloc[0] == "Passed"
            and p2["Outcome"].iloc[0] == "Passed"):
            outcome = "Passed"
        else:
            outcome = "Failed"
            if not p1.empty and p1["Outcome"].iloc[0] == "Failed":
                failedPhase1Count += 1
            elif not p2.empty and p2["Outcome"].iloc[0] == "Failed":
                failedPhase2Count += 1
            else:
                failedPhase1Count += 1  # if only phase1 exists

        challenge_records.append({
            "keys": keys,
            "Outcome": outcome,
            "Duration": totalDuration,
            "completion_row": completion_row
        })

    # Sort by actual completion order
    challenge_df = pd.DataFrame(challenge_records).sort_values("completion_row").reset_index(drop=True)

    totalChallenges = len(challenge_df)
    totalWonChallenges = (challenge_df["Outcome"] == "Passed").sum()
    totalFailedChallenges = (challenge_df["Outcome"] == "Failed").sum()

    winrate = round((totalWonChallenges / totalChallenges) * 100, 2) if totalChallenges else 0
    averageDurationTotal = round(challenge_df["Duration"].mean(), 2) if totalChallenges else 0
    averageDurationPassed = round(challenge_df[challenge_df["Outcome"] == "Passed"]["Duration"].mean(), 2) if totalWonChallenges else 0
    averageDurationFailed = round(challenge_df[challenge_df["Outcome"] == "Failed"]["Duration"].mean(), 2) if totalFailedChallenges else 0

    # Consecutive streaks based on chronological completion
    series = challenge_df["Outcome"]
    groups = (series != series.shift()).cumsum()
    streaks = series.groupby(groups).agg(["first", "size"])

    winStreaks = streaks[streaks["first"] == "Passed"]["size"]
    lossStreaks = streaks[streaks["first"] == "Failed"]["size"]

    maxConsecutiveWins = int(winStreaks.max()) if not winStreaks.empty else 0
    maxConsecutiveLosses = int(lossStreaks.max()) if not lossStreaks.empty else 0
    averageConsecutiveWins = round(winStreaks.mean(), 2) if not winStreaks.empty else 0
    averageConsecutiveLosses = round(lossStreaks.mean(), 2) if not lossStreaks.empty else 0

    failedPhase1Percentage = round((failedPhase1Count / totalFailedChallenges) * 100, 2) if totalFailedChallenges else 0
    failedPhase2Percentage = round((failedPhase2Count / totalFailedChallenges) * 100, 2) if totalFailedChallenges else 0

    return {
        "Challenges": totalChallenges,
        "Won": totalWonChallenges,
        "Loss": totalFailedChallenges,
        "Winrate (%)": winrate,
        "Avg Duration Total": averageDurationTotal,
        "Avg Duration Passed": averageDurationPassed,
        "Avg Duration Failed": averageDurationFailed,
        "Max Cons Wins": maxConsecutiveWins,
        "Max Cons Losses": maxConsecutiveLosses,
        "Avg Cons Wins": averageConsecutiveWins,
        "Avg Cons Losses": averageConsecutiveLosses,
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

    # Group by both Strategy and Challenge Number
    challengeGroups = df.groupby(["Strategy", "Challenge Number"])
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

    for _, group in challengeGroups:
        group = group.sort_values("Phase")
        payouts = group[group["Outcome"] == "Payout"]
        totalDuration = group["Duration"].sum()
        challengeDurations.append(totalDuration)

        if not payouts.empty:
            # Challenge passed (at least 1 payout)
            challengeWins += 1
            totalPayouts += len(payouts)
            passedDurations.append(totalDuration)
            challengeOutcomes.append("Payout")
            payoutProfits.extend((payouts["Ending Balance"] - payouts["Start Balance"]).tolist())
        else:
            # Challenge failed (no payouts at all)
            totalFailedChallenges += 1
            failedDurations.append(totalDuration)
            challengeOutcomes.append("Failed")

        # Consecutive payouts within this challenge
        outcome_series = (group["Outcome"] == "Payout").astype(int)
        streak_groups = (outcome_series != outcome_series.shift()).cumsum()
        streaks = outcome_series.groupby(streak_groups).sum()
        if not streaks.empty:
            allChallengePayoutStreaks.extend(streaks[streaks > 0].tolist())

    # BASIC METRICS
    challengeWinrate = round((challengeWins / totalChallenges) * 100, 2) if totalChallenges else 0
    payoutWinrate = round((totalPayouts / (totalPayouts + totalFailedChallenges)) * 100, 2) if (totalPayouts + totalFailedChallenges) else 0
    averageDurationTotal = round(sum(challengeDurations) / len(challengeDurations), 2) if challengeDurations else 0
    averageDurationPassed = round(sum(passedDurations) / len(passedDurations), 2) if passedDurations else 0
    averageDurationFailed = round(sum(failedDurations) / len(failedDurations), 2) if failedDurations else 0
    
    # MAX CONSECUTIVE WINS/LOSSES
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
    for challengeNum, group in df.groupby("Challenge Number"):
        payouts = group[group["Outcome"] == "Payout"]
        if not payouts.empty:
            totalProfit = (payouts["Ending Balance"] - payouts["Start Balance"]).sum()
        else:
            totalProfit = -80
        totalChallengeProfits.append(totalProfit)
    averageTotalProfitPerChallenge = round(sum(totalChallengeProfits) / len(totalChallengeProfits))

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
    csvFile = metricsFolder / "MONTHLY_FUNDED.csv"
    monthlyDF.to_csv(csvFile, index=False, encoding='utf-16', sep='\t')

    return {
        "Challenge WR": challengeWinrate,
        "Failed Challenges": totalFailedChallenges,
        "Payout Winrate": payoutWinrate,
        "Avg Duration Total": averageDurationTotal,
        "Avg Duration Passed": averageDurationPassed,
        "Avg Duration Failed": averageDurationFailed,
        "Max Cons Wins (Challenges)": maxConsecutiveWins,
        "Max Cons Losses (Challenges)": maxConsecutiveLosses,
        "Avg Cons Wins (Challenges)": averageConsecutiveWins,
        "Avg Cons Losses (Challenges)": averageConsecutiveLosses,
        "Max Cons Payouts": maxConsecutivePayoutsPerChallenge,
        "Avg Payouts Challenge": averageConsecutivePayoutsPerChallenge,
        "Avg Profit Payout ($)": averageProfitPerPayout,
        "Avg Profit Challenge": averageTotalProfitPerChallenge,
        "Winning Months": winningMonths,
        "Loosing Months": losingMonths,
        "Monthly Winrate": monthlyWinrate,
        "Avg Monthly Profit": averageMonthlyProfit,
        "Avg Monthly Loss": averageMonthlyLoss,
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

# =======================
# GENERATE HTML REPORT
# =======================

metricsFiles = [
    "METRICS_PHASE1&2.csv",
    "METRICS_PHASE3.csv",
    "METRICS_CHALLENGE.csv",
    "METRICS_FUNDED.csv",
]
originalFiles = [
    "PHASE1.csv",
    "PHASE2.csv",
    "PHASE3.csv",
    "CHALLENGE.csv",
    "FUNDED.csv",
]

htmlSections=[]

for fileName in metricsFiles:
    filePath = metricsFolder / fileName
    df = readCSV(filePath)
    if df is not None:
        sectionTitle = fileName.replace("METRICS_", "").replace(".csv", "")
        sectionHTML = df.to_html(index=False)
        htmlSections.append(f"<h2>{sectionTitle}</h2>\n{sectionHTML}")

for fileName in originalFiles:
    filePath = fullPath / fileName
    df = readCSV(filePath)
    if df is not None:
        sectionTitle = fileName.replace(".csv", "")
        sectionHTML = df.to_html(index=False)
        htmlSections.append(f"<h2>Raw Data - {sectionTitle}</h2>\n{sectionHTML}")
    
fullHTML = "\n<hr>\n".join(htmlSections)
cssContent = Path("reportStyle.css").read_text()

htmlTemplate = f"""
<html>
<head>
    <title>Simulation Report</title>
    <style>{cssContent}</style>
</head>
<body>
    <h1><a>Simulation Report </a> - {subfolder}</h1>
    {fullHTML}
</body>
</html>
"""

htmlOutput = fullPath / f"REPORT.html"

with open(htmlOutput, "w", encoding="utf-16") as f:
    f.write(htmlTemplate)

webbrowser.open(str(htmlOutput))
