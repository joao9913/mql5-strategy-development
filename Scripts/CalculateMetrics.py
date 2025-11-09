import pandas as pd
from pathlib import Path
import os 
import csv

# ==========================
# CONFIGURATION 
# ==========================

baseFolder = Path(r"C:\Users\João Pereira\AppData\Roaming\MetaQuotes\Terminal\Common\Files\SimulationData")
#subfolder = input("Specify the subfolder of the simulation reports: ")
subfolder = "MiddleRange_USDJPY_2025-11-08_10;26;30"
fullPath = baseFolder / subfolder

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

def calculatePhaseMetrics(df):
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
        "Average Duration (Days)": averageDuration,
        "Average Duration When Passed (Days)": averagePassedDuration,
        "Average Duration When Failed (Days)": averageFailedDuration,
        "Max Consecutive Wins": maxConsWins,
        "Max Consecutive Losses": maxConsLosses,
        "Average Consecutive Wins": averageConsWins,
        "Average Consecutive Losses": averageConsLosses
    }

def calculatePayoutMetrics(df):
    df["Duration"] = df["Duration"].astype(float)
    outcomeSeries = df["Outcome"]

    # Metrics for phase 1 and phase 2
    totalPassed = (outcomeSeries == "Payout").sum()
    totalFailed = (outcomeSeries == "Failed").sum()
    totalOutcomes = totalPassed + totalFailed
    winrate = round((totalPassed / totalOutcomes) * 100, 2) if totalOutcomes else 0
    averageDuration = round(df["Duration"].astype(float).mean(), 2) if totalOutcomes else 0
    averagePassedDuration = round(df[df["Outcome"]=="Payout"]["Duration"].mean(), 2)
    averageFailedDuration = round(df[df["Outcome"]=="Failed"]["Duration"].mean(), 2)

    #Consecutive wins/losses
    passedGroups = (outcomeSeries == "Payout").astype(int).groupby((outcomeSeries != outcomeSeries.shift()).cumsum()).sum()
    failedGroups = (outcomeSeries == "Failed").astype(int).groupby((outcomeSeries != outcomeSeries.shift()).cumsum()).sum()
    maxConsWins = passedGroups.max()
    maxConsLosses = failedGroups.max()
    averageConsWins = round(passedGroups.mean(), 2)
    averageConsLosses = round(failedGroups.mean(), 2)

    return{
        "Total Payouts": totalPassed,
        "Total Failed": totalFailed,
        "Winrate (%)": winrate,
        "Average Duration (Days)": averageDuration,
        "Average Duration When Payout (Days)": averagePassedDuration,
        "Average Duration When Failed (Days)": averageFailedDuration,
        "Max Consecutive Payouts": maxConsWins,
        "Max Consecutive Losses": maxConsLosses,
        "Average Consecutive Payouts": averageConsWins,
        "Average Consecutive Losses": averageConsLosses
    }

#Map phase type to function
metricFunctions = {
    "PHASE1": calculatePhaseMetrics,
    "PHASE2": calculatePhaseMetrics,
    "PHASE3": calculatePayoutMetrics,
    "CHALLENGE": calculatePhaseMetrics,
    "FUNDED": calculatePhaseMetrics
}

# =======================
# PROCESS CSV FILES
# =======================

groupedMetrics = {
    "PHASE": {},
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
            if "PHASE" in phaseType:
                groupedMetrics["PHASE"][fileName.replace(".csv", "")] = metrics
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
SaveMetrics("PHASES", groupedMetrics["PHASE"])
SaveMetrics("CHALLENGE", groupedMetrics["CHALLENGE"])
SaveMetrics("FUNDED", groupedMetrics["FUNDED"])