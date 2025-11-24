import pandas as pd
from pathlib import Path
import os

#--- CONFIG ---
HTML_TEMPLATE = Path("Templates/reportHTML.html")
CSS_TEMPLATE = Path("Templates/reportStyle.css")

commonFolder = Path(os.getenv("APPDATA")) / "MetaQuotes" / "Terminal" / "Common" / "Files" / "SimulationData"

SIMULATION_ROOT = Path("")