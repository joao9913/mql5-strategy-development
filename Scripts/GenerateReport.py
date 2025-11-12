import pandas as pd
from pathlib import Path
import os

# ==========================
# CONFIGURATION 
# ==========================

#Automatically find MT5 Common Folder
commonFolder = Path(os.getenv("APPDATA")) / "MetaQuotes" / "Terminal" / "Common" / "Files" / "SimulationData"
subfolder = "HourBreakout_USDJPY_2025-11-12_16;06;14"
#subfolder = input("Specify the folder of the simulation reports: ")
simulationPath = commonFolder / subfolder

reportPath = f"{simulationPath}/FUNDED.csv"
metricsPath = f"{simulationPath}/METRICS/METRICS_FUNDED.csv"
reportDF = pd.read_csv(reportPath, encoding='utf-16', sep='\t')
metricsDF = pd.read_csv(metricsPath, encoding='utf-16', sep='\t')

# ==========================
# CONVERT TO HTML
# ==========================

reportTable = reportDF.to_html(index=False)
metricsTable = metricsDF.to_html(index=False)

htmlContent = f"""
<html>
<head>
    <title>Funded Report</title>
    <style>
        body {{font-family: Poppins; font-size: 10px; margin: 50px; background-color: #0b0b0b; color: #e3e3e3; }}
        table {{border-collapse: collapse; width: 100%; }}
        th {{background-color: #192426; color: #e3e3e3; text-transform: capitalize; font-size: 12px; font-weight: normal; border: 1px solid #212121; text-align: center; padding: 6px 20px;}}
        td {{font-size: 11px; font-weight: normal; border: 1px solid #212121; padding: 5px 20px; text-align: center; }}
        h1 {{text-transform: uppercase; font-weight: normal; color: #66bbcc; margin-bottom: 50px; margin-top: 100px; }}
    </style>
</head>
<body>
    <h1>Funded Metrics</h1>
    {metricsTable}
    <h1>Simulation Report</h1>
    {reportTable}
</body
</html>
"""

# ==========================
# SAVE HTML
# ==========================
outputFile = f"{simulationPath}/FUNDED_REPORT.html"

with open(outputFile, "w", encoding="utf-16") as f:
    f.write(htmlContent)
