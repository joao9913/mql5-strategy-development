import pandas as pd
from pathlib import Path
import os 

# ==========================
# CONFIGURATION 
# ==========================

#Automatically find MT5 Common Folder
commonFolder = Path(os.getenv("APPDATA")) / "MetaQuotes" / "Terminal" / "Common" / "Files" / "SimulationData" / "JoinSimulations"
if not commonFolder.exists():
    raise FileNotFoundError(f"Folder not found: {commonFolder}")

#Check if there are any folders to merge
subfolders = [f for f in commonFolder.iterdir() if f.is_dir()]
if not subfolders:
    print(f"No subfolders found in {commonFolder}. No simulations to merge.")
    exit()

# ==========================
# LOAD & MERGE CSVs
# ==========================

mergedDF = pd.DataFrame()

allDFS = []

for subfolder in commonFolder.iterdir():
    if subfolder.is_dir():
        phase1File = subfolder / "PHASE1.CSV"
        if phase1File.exists():
            df = pd.read_csv(phase1File, encoding='utf-16', sep='\t')

            strategyName = subfolder.name.split("_")[0]
            df["Strategy"] = strategyName

            cols = ["Strategy"] + [c for c in df.columns if c != "Strategy"]
            df = df[cols]

            mergedDF = pd.concat([mergedDF, df], ignore_index=True)
        else:
            print(f"PHASE1.CSV not found in {subfolder}")
    
outputFile = commonFolder / "PHASE1.csv"
mergedDF["End Phase Date"] = pd.to_datetime(mergedDF["End Phase Date"], errors="coerce")
mergedDF = mergedDF.sort_values("End Phase Date").reset_index(drop=True)
mergedDF["End Phase Date"] = mergedDF["End Phase Date"].dt.strftime("%Y.%m.%d")
mergedDF.to_csv(outputFile, index=False, encoding='utf-16', sep='\t')
print(f"Merged simulations saved to: {outputFile}")