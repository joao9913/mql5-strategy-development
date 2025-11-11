import pandas as pd
from pathlib import Path
import os 
from datetime import datetime

# ==========================
# CONFIGURATION 
# ==========================

#Automatically find MT5 Common Folder
commonFolder = Path(os.getenv("APPDATA")) / "MetaQuotes" / "Terminal" / "Common" / "Files" / "SimulationData"

joinFolder = commonFolder / "JoinSimulations"
joinFolder.mkdir(exist_ok=True)

#Check if there are any folders to merge
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
mergedFolder = joinFolder / f"MergedSimulations{timestamp}"
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