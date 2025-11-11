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

            mergedDF = pd.concat([mergedDF, df], ignore_index=True)
        else:
            print(f"PHASE1.CSV not found in {subfolder}")
    
outputFile = commonFolder / "PHASE1_MERGED.csv"
mergedDF.to_csv(outputFile, index=False)
print(f"Merged simulations saved to: {outputFile}")