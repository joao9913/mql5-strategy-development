import pandas as pd
from pathlib import Path
import os 
from datetime import datetime
import webbrowser

# ==========================
# CONFIGURATION 
# ==========================

# Automatically find MT5 Common Folder
commonFolder = Path(os.getenv("APPDATA")) / "MetaQuotes" / "Terminal" / "Common" / "Files" / "SimulationData"

joinFolder = commonFolder / "JoinSimulations"
joinFolder.mkdir(exist_ok=True)

# Check if there are any folders to merge
subfolders = [f for f in joinFolder.iterdir() if f.is_dir()]
if not subfolders:
    print(f"No subfolders found in {joinFolder}. No simulations to merge.")
    exit()

folderFiles = [set(f.name for f in sf.glob("*.csv")) for sf in subfolders]
commonFiles = set.intersection(*folderFiles)
if not commonFiles:
    print("No common CSV files found across all subfolders. Exiting.")
    exit()

timestamp = datetime.now().strftime("_%Y-%m-%d_%H;%M;%S")
mergedFolder = commonFolder / f"MergedSimulations{timestamp}"
mergedFolder.mkdir(exist_ok=True)

# ==========================
# LOAD & MERGE CSVs
# ==========================

for fileName in commonFiles:
    allData = []
    
    for subfolder in subfolders:
        strategyName = subfolder.name.split("_")[0]
        filePath = joinFolder / subfolder / fileName
        df = pd.read_csv(filePath, encoding='utf-16', sep='\t')
        df["Strategy"] = strategyName
        allData.append(df)
    
    if allData:
        merged_df = pd.concat(allData, ignore_index=True)
        
        # Put Strategy as first column
        cols = merged_df.columns.tolist()
        cols.insert(0, cols.pop(cols.index("Strategy")))
        merged_df = merged_df[cols]
        
        # Sort by End Phase Date if exists
        if "End Phase Date" in merged_df.columns:
            merged_df["End Phase Date"] = pd.to_datetime(merged_df["End Phase Date"], errors="coerce")
            merged_df = merged_df.sort_values("End Phase Date").reset_index(drop=True)
            merged_df["End Phase Date"] = merged_df["End Phase Date"].dt.strftime("%Y.%m.%d")
        
        # Save merged file
        output_file = mergedFolder / f"{fileName.split('.')[0]}.csv"
        merged_df.to_csv(output_file, index=False, encoding='utf-16', sep='\t')
        print(f"Merged {fileName} saved to: {output_file}")

# ==========================
# MERGE METRICS
# ==========================

phaseTypes = ["PHASE1", "PHASE2", "PHASE3", "CHALLENGE", "FUNDED"]
mergedMetricsFolder = mergedFolder / "Metrics"
mergedMetricsFolder.mkdir(exist_ok=True)

for phase in phaseTypes:
    allMetrics = []

    for subfolder in subfolders:
        metricsFolder = subfolder / "Metrics"
        metricsFile = metricsFolder / f"METRICS_{phase}.csv"
        if metricsFile.exists():
            df = pd.read_csv(metricsFile, encoding='utf-16', sep='\t')
            df.insert(0, "Simulation", subfolder.name)  # Track which simulation/subfolder
            allMetrics.append(df)

    if allMetrics:
        mergedMetrics = pd.concat(allMetrics, ignore_index=True)
        
        # ==========================
        # ADD TOTAL ROW
        # ==========================
        countCols = ["Nº Passed", "Nº Failed", "Nº Payouts", "Challenges", "Won", "Loss",
                     "Winning Months", "Loosing Months", "Failed Challenges", "Total Payouts ($)", "Total Failed ($)"]
        percentageCols = ["Winrate (%)", "Payout Winrate", "Challenge WR", "Monthly Winrate",
                          "% Failed Phase 1", "% Failed Phase 2", "Efficiency Ratio", "Profitability Ratio", 
                          "Profitability Ratio Payout", "Profitability Ratio Monthly"]
        avgCols = ["Avg Duration", "Avg Duration Passed", "Avg Duration Failed", "Avg Duration Total", 
                   "Avg Duration Payout", "Avg Cons Wins", "Avg Cons Losses", "Avg Cons Payouts",
                   "Avg Payouts Challenge", "Avg Profit Payout ($)", "Avg Profit Challenge", 
                   "Avg Monthly Profit", "Avg Monthly Loss", "Avg Payout($)", "Profit Factor", 
                   "Avg Cons Wins (Challenges)", "Avg Cons Losses (Challenges)", "Monthly W/L Ratio"]
        maxCols = ["Max Cons Wins", "Max Cons Losses", "Max Cons Payouts",
                   "Max Cons Wins (Challenges)", "Max Cons Losses (Challenges)"]

        summary = {"Simulation": "TOTAL"}

        for col in mergedMetrics.columns:
            if col in countCols:
                summary[col] = mergedMetrics[col].sum()
            elif col in percentageCols or col in avgCols:
                summary[col] = round(mergedMetrics[col].mean(), 2)
            elif col in maxCols:
                summary[col] = mergedMetrics[col].max()
            elif col == "Simulation":
                continue
            else:
                summary[col] = ""

        mergedMetrics = pd.concat([mergedMetrics, pd.DataFrame([summary])], ignore_index=True)

        # Save merged metrics
        output_file = mergedMetricsFolder / f"METRICS_{phase}.csv"
        mergedMetrics.to_csv(output_file, index=False, encoding='utf-16', sep='\t')
        print(f"Merged metrics for {phase} saved to: {output_file}")

# ==========================
# GENERATE HTML REPORT
# ==========================

cssPath = Path("reportStyle.css")
cssContent = cssPath.read_text() if cssPath.exists() else ""

htmlSections = []

for metricsFile in mergedMetricsFolder.glob("METRICS_*.csv"):
    df = pd.read_csv(metricsFile, encoding='utf-16', sep='\t')
    if df is not None and not df.empty:
        sectionTitle = metricsFile.stem.replace("METRICS_", "")
        
        # Move TOTAL row to the top
        if "TOTAL" in df["Simulation"].values:
            totalRow = df[df["Simulation"] == "TOTAL"]
            otherRows = df[df["Simulation"] != "TOTAL"]
            df = pd.concat([totalRow, otherRows], ignore_index=True)

        sectionHTML = df.to_html(index=False)
        htmlSections.append(f"<h2>{sectionTitle}</h2>\n{sectionHTML}")

# Combine all sections
fullHTML = "\n<hr>\n".join(htmlSections)

# HTML template
htmlTemplate = f"""
<html>
<head>
    <title>Merged Simulation Metrics Report</title>
    <style>{cssContent}</style>
</head>
<body>
    <h1>Merged Simulation Metrics Report</h1>
    {fullHTML}
</body>
</html>
"""

# Save HTML report
htmlOutput = mergedMetricsFolder / "MERGED_METRICS_REPORT.html"
with open(htmlOutput, "w", encoding="utf-16") as f:
    f.write(htmlTemplate)

# Open in default browser
#webbrowser.open(str(htmlOutput))