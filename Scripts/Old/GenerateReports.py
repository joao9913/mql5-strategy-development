import pandas as pd
import numpy as np
from pathlib import Path
import os
import csv

# ==========================
# FILE CONFIGURATION
# ==========================

common_folder = Path(os.getenv("APPDATA")) / "MetaQuotes"/"Terminal"/"Common"/"Files"/"SimulationData"
calculate_metrics_folder = common_folder/"CalculateMetrics"
calculate_metrics_folder.mkdir(exist_ok=True)
simulation_folders = [f for f in calculate_metrics_folder.iterdir() if f.is_dir()]
if not simulation_folders:
    print("No simulation folders found inside CalculateMetrics.")
    exit()

print("Detected simulation folders:")
for f in simulation_folders:
    print(" -", f.name)

# Define expected CSV files per phase type
phase_files = {
    "PHASE1": ["PHASE1.csv"], 
    "PHASE2": ["PHASE2.csv"], 
    "PHASE3": ["PHASE3.csv"], 
    "CHALLENGE": ["CHALLENGE.csv"], 
    "FUNDED": ["FUNDED.csv"]
}

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

def calculate_phase_metrics(df):
    df["Duration"] = df["Duration"].astype(float)
    outcome_series = df["Outcome"]
    
    total_passed = (outcome_series == "Passed").sum()
    total_failed = (outcome_series == "Failed").sum()
    total_outcomes = total_passed + total_failed
    winrate = round((total_passed / total_outcomes) * 100, 2) if total_outcomes else 0
    average_duration = round(df["Duration"].mean(), 2) if total_outcomes else 0
    average_passed_duration = round(df[df["Outcome"] == "Passed"]["Duration"].mean(), 2) if total_passed else 0
    average_failed_duration = round(df[df["Outcome"] == "Failed"]["Duration"].mean(), 2) if total_failed else 0

    # Consecutive Wins & Losses
    passed_groups = calculate_consecutive(outcome_series, "Passed")
    failed_groups = calculate_consecutive(outcome_series, "Failed")
    max_consecutive_wins = passed_groups.max() if not passed_groups.empty else 0
    max_consecutive_losses = failed_groups.max() if not failed_groups.empty else 0
    average_consecutive_wins = round(passed_groups.mean(), 2) if not passed_groups.empty else 0
    average_consecutive_losses = round(failed_groups.mean(), 2) if not failed_groups.empty else 0
    efficiency_ratio = round(winrate / average_duration, 2)

    return{
        "Nº Passed": total_passed,
        "Nº Failed": total_failed,
        "Winrate": winrate,
        "Average Duration": average_duration,
        "Average Duration Passed": average_passed_duration,
        "Average Duration Failed": average_failed_duration,
        "Max Consecutive Wins": max_consecutive_wins,
        "Max Consecutive Losses": max_consecutive_losses,
        "Average Consecutive Wins": average_consecutive_wins,
        "Average Consecutive Losses": average_consecutive_losses,
        "Efficiency Ratio": efficiency_ratio
    }

def calculate_payout_metrics(df):
    df["Duration"] = df["Duration"].astype(float)
    df["Start Balance"] = df["Start Balance"].astype(float)
    df["Ending Balance"] = df["Ending Balance"].astype(float)
    outcome_series = df["Outcome"]
    
    total_passed = (outcome_series == "Payout").sum()
    total_failed = (outcome_series == "Failed").sum()
    total_outcomes = total_passed + total_failed
    winrate = round((total_passed / total_outcomes) * 100, 2) if total_outcomes else 0
    average_duration = round(df["Duration"].mean(), 2) if total_outcomes else 0
    average_passed_duration = round(df[df["Outcome"] == "Payout"]["Duration"].mean(), 2) if total_passed else 0
    average_failed_duration = round(df[df["Outcome"] == "Failed"]["Duration"].mean(), 2) if total_failed else 0

    # Consecutive Wins & Losses
    passed_groups = calculate_consecutive(outcome_series, "Payout")
    failed_groups = calculate_consecutive(outcome_series, "Failed")
    max_consecutive_wins = passed_groups.max() if not passed_groups.empty else 0
    max_consecutive_losses = failed_groups.max() if not failed_groups.empty else 0
    average_consecutive_wins = round(passed_groups.mean(), 2) if not passed_groups.empty else 0
    average_consecutive_losses = round(failed_groups.mean(), 2) if not failed_groups.empty else 0

    # Payout Metrics
    payout_rows = df[df["Outcome"] == "Payout"].copy()
    payout_rows["Payout Amount"] = payout_rows["Ending Balance"] - payout_rows["Start Balance"]
    average_payout = round(payout_rows["Payout Amount"].mean(), 2) if not payout_rows.empty else 0
    total_payouts = round(payout_rows["Payout Amount"].sum(), 2) if not payout_rows.empty else 0
    gross_loss = total_failed * 80
    profit_factor = round(total_payouts / gross_loss, 2) if gross_loss != 0 else float('inf')
    profitability_ratio = round(((winrate / 100 * average_payout) / 80) * 10, 2)

    return{
        "Nº Payouts": total_passed,
        "Nº Failed": total_failed,
        "Winrate": winrate,
        "Average Duration": average_duration,
        "Average Duration Payouts": average_passed_duration,
        "Average Duration Failed": average_failed_duration,
        "Max Consecutive Payouts": max_consecutive_wins,
        "Max Consecutive Losses": max_consecutive_losses,
        "Average Consecutive Payouts": average_consecutive_wins,
        "Average Consecutive Losses": average_consecutive_losses,
        "Average Payout": average_payout,
        "Total Payouts": total_payouts,
        "Total Loss": gross_loss,
        "Profit Factor": profit_factor,
        "Profitability Ratio": profitability_ratio
    }

def calculate_challenge_metrics(df):
    df = df.copy().reset_index(drop=False).rename(columns={"index": "_row_index"})
    df["Outcome"] = df["Outcome"].astype(str).str.strip()
    df["Phase"] = pd.to_numeric(df["Phase"], errors="coerce").fillna(0).astype(int)
    df["Duration"] = pd.to_numeric(df["Duration"], errors="coerce").fillna(0)

    # Group by strategy and challenge
    if "Strategy" in df.columns:
        challenge_groups = df.groupby(["Strategy", "Challenge Number"])
    else:
        challenge_groups = df.groupby("Challenge Number")
    
    challenge_records = []
    failed_p1_count = failed_p2_count = 0

    for(keys), group in challenge_groups:
        p1 = group[group["Phase"] == 1]
        p2 = group[group["Phase"] == 2]
        total_duration = group["Duration"].sum()

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
                failed_p1_count += 1
            elif not p2.empty and p2["Outcome"].iloc[0] == "Failed":
                failed_p2_count += 1
            else:
                failed_p1_count += 1
        
        challenge_records.append({
            "keys": keys,
            "Outcome": outcome,
            "Duration": total_duration,
            "completion_row": completion_row
        })

    # Sort by completion order
    challenge_df = pd.DataFrame(challenge_records).sort_values("completion_row").reset_index(drop=True)
    total_challenges = len(challenge_df)
    total_won_challenges = (challenge_df["Outcome"] == "Passed").sum()
    total_failed_challenges = (challenge_df["Outcome"] == "Failed").sum()
    winrate = round((total_won_challenges / total_challenges) * 100, 2) if total_challenges else 0
    average_duration_total = round(challenge_df["Duration"].mean(), 2) if total_challenges else 0
    average_duration_passed = round(challenge_df[challenge_df["Outcome"] == "Passed"]["Duration"].mean(), 2) if total_won_challenges else 0
    average_duration_failed = round(challenge_df[challenge_df["Outcome"] == "Failed"]["Duration"].mean(), 2) if total_failed_challenges else 0

    # Consecutive streaks based on chronological completion
    series = challenge_df["Outcome"]
    groups = (series != series.shift()).cumsum()
    streaks = series.groupby(groups).agg(["first", "size"])
    win_streak = streaks[streaks["first"] == "Passed"]["size"]
    loss_streak = streaks[streaks["first"] == "Failed"]["size"]
    max_consecutive_wins = int(win_streak.max()) if not win_streak.empty else 0
    max_consecutive_losses = int(loss_streak.max()) if not loss_streak.empty else 0
    average_consecutive_wins = round(win_streak.mean(), 2) if not win_streak.empty else 0
    average_consecutive_losses = round(loss_streak.mean(), 2) if not loss_streak.empty else 0

    failed_p1_percentage = round((failed_p1_count / total_failed_challenges) * 100, 2) if total_failed_challenges else 0
    failed_p2_percentage = round((failed_p2_count / total_failed_challenges) * 100, 2) if total_failed_challenges else 0
    efficiciency_ratio = round(winrate / average_duration_total, 2)

    return{
        "Nº Challenges": total_challenges,
        "Nº Passed": total_won_challenges,
        "Nº Failed": total_failed_challenges,
        "Winrate": winrate,
        "Average Duration Total": average_duration_total,
        "Average Duration Passed": average_duration_passed,
        "Average Duration Failed": average_duration_failed,
        "Max Consecutive Wins": max_consecutive_wins,
        "Max Consecutive Losses": max_consecutive_losses,
        "Average Consecutive Wins": average_consecutive_wins,
        "Average Consecutive Losses": average_consecutive_losses,
        "Failed Phase 1 %": failed_p1_percentage,
        "Failed Phase 2 %": failed_p2_percentage,
        "Efficiency Ratio": efficiciency_ratio
    }

def calculate_funded_metrics(df):
    df["Outcome"] = df["Outcome"].astype(str).str.strip()
    df["Phase"] = pd.to_numeric(df["Phase"], errors="coerce").fillna(0).astype(int)
    df["Duration"] = pd.to_numeric(df["Duration"], errors="coerce").fillna(0).astype(int)
    df["Start Balance"] = pd.to_numeric(df["Start Balance"], errors="coerce").fillna(0).astype(int)
    df["Ending Balance"] = pd.to_numeric(df["Ending Balance"], errors="coerce").fillna(0).astype(int)

    # Group by strategy and challenge number

    challenge_groups = df.groupby(["Challenge Number"])
    total_challenges = challenge_groups.ngroups
    challenge_wins = 0
    total_payouts = 0
    total_failed = 0
    challenge_durations = []
    passed_durations = []
    failed_durations = []
    challenge_outcomes = []
    payout_profits = []

    # Process each challenge
    for _, group in challenge_groups:
        group = group.sort_values("Phase")
        payouts = group[group["Outcome"] == "Payout"]
        total_duration = group["Duration"].sum()
        challenge_durations.append(total_duration)

        if not payouts.empty:
            # Challenge passed (at least 1 payout)
            challenge_wins += 1
            total_payouts += len(payouts)
            passed_durations.append(total_duration)
            challenge_outcomes.append("Payout")
            payout_profits.extend((payouts["Ending Balance"] - payouts["Start Balance"]).tolist())
        else:
            # Challenge failed (no payouts at all)
            total_failed += 1
            failed_durations.append(total_duration)
            challenge_outcomes.append("Failed")
    
    # Basic Metrics
    challenge_winrate = round((challenge_wins / total_challenges) * 100, 2) if total_challenges else 0
    payout_winrate = round((total_payouts / (total_payouts + total_failed)) * 100, 2) if (total_payouts + total_failed) else 0
    average_duration_total = round(sum(challenge_durations) / len(challenge_durations), 2) if challenge_durations else 0
    average_duration_passed = round(sum(passed_durations) / len(passed_durations), 2) if passed_durations else 0
    average_duration_failed = round(sum(failed_durations) / len(failed_durations), 2) if failed_durations else 0

    # Consecutive wins/losses per challenge
    if challenge_outcomes:
        series = pd.Series(challenge_outcomes)
        groups = (series != series.shift()).cumsum()
        streaks = series.groupby(groups).agg(['first', 'size'])
        win_streaks = streaks[streaks['first'] == 'Payout']['size']
        loss_streaks = streaks[streaks['first'] == 'Failed']['size']
        max_consecutive_wins = int(win_streaks.max()) if not win_streaks.empty else 0
        max_consecutive_losses = int(loss_streaks.min()) if not loss_streaks.empty else 0
        average_consecutive_passed = round(win_streaks.mean(), 2) if not win_streaks.empty else 0
        average_consecutive_failed = round(loss_streaks.mean(), 2) if not loss_streaks.empty else 0
    else:
        max_consecutive_wins = max_consecutive_losses = average_consecutive_passed = average_consecutive_failed = 0
    
    # Max consecutive payouts 
    df_sorted = df.sort_values(["Challenge Number", "Phase"])
    all_payout_series = (df_sorted["Outcome"] == "Payout").astype(int)
    streak_groups = (all_payout_series != all_payout_series.shift()).cumsum()
    streaks = all_payout_series.groupby(streak_groups).sum()
    all_challenge_payout_streaks = streaks[streaks > 0].tolist()
    max_consecutive_payouts_challenge = max(all_challenge_payout_streaks) if all_challenge_payout_streaks else 0
    average_consecutive_payouts_challenge = round(sum(all_challenge_payout_streaks) / len(all_challenge_payout_streaks), 2) if all_challenge_payout_streaks else 0

    # Profit metrics
    average_profit_payout = round(sum(payout_profits) / len(payout_profits), 2) if payout_profits else 0
    total_challenge_profits = []
    for _, group in df.groupby("Challenge Number"):
        payouts = group[group["Outcome"] == "Payout"]
        total_profit = (payouts["Ending Balance"] - payouts["Start Balance"]).sum() if not payouts.empty else -80
        total_challenge_profits.append(total_profit)
    average_total_profit_challenge = round(sum(total_challenge_profits) / len(total_challenge_profits), 2) if total_challenge_profits else 0

    # Monthly metrics
    df["End Phase Date"] = pd.to_datetime(df["End Phase Date"], errors="coerce")
    df["PnL"] = np.where(
        df["Outcome"] == "Payout",
        df["Ending Balance"] - df["Start Balance"],
        np.where(df["Outcome"] == "Failed", -80, 0)
    )

    df["Month"] = df["End Phase Date"].dt.to_period("M").astype(str)
    monthly_PnL = df.groupby("Month")["PnL"].sum()
    winning_months = int((monthly_PnL > 0).sum())
    losing_months = int((monthly_PnL <= 0).sum())
    monthly_winrate = round((winning_months / (winning_months + losing_months)) * 100, 2) if (winning_months + losing_months) else 0
    average_monthly_profit = round(monthly_PnL[monthly_PnL > 0].mean(), 2) if (monthly_PnL > 0).any() else 0
    average_monthly_loss = round(monthly_PnL[monthly_PnL <= 0].mean(), 2) if(monthly_PnL <= 0).any() else 0
    monthly_wl_ratio = round(winning_months / losing_months, 2) if losing_months > 0 else float('inf')
    profitability_ratio_payout = round(((payout_winrate / 100) * average_consecutive_payouts_challenge * average_profit_payout) / 80, 2)
    profitability_ratio_monthly = round(((monthly_winrate / 100) * average_monthly_profit) / (average_monthly_loss * -1), 2)

    return {
        "Challenge Winrate": challenge_winrate,
        "Failed Challenges": total_failed,
        "Payout Winrate": payout_winrate,
        "Average Duration Total": average_duration_total,
        "Average Duration Passed": average_duration_passed,
        "Average Duration Failed": average_duration_failed,
        "Max Consecutive Wins": max_consecutive_wins,
        "Max Consecutive Losses": max_consecutive_losses,
        "Average Consecutive Wins": average_consecutive_passed,
        "Average Consecutive Losses": average_consecutive_failed,
        "Max Consecutive Payouts": max_consecutive_payouts_challenge,
        "Average Payouts Per Challenge": average_consecutive_payouts_challenge,
        "Average Profit Per Payout": average_profit_payout,
        "Average Profit Per Challenge": average_total_profit_challenge,
        "Winning Months": winning_months,
        "Losing Months": losing_months,
        "Monthly Winrate": monthly_winrate,
        "Average Monthly Profit": average_monthly_profit,
        "Average Monthly Loss": average_monthly_loss,
        "Monthly W/L Ratio": monthly_wl_ratio,
        "Profitability Ratio Payout": profitability_ratio_payout,
        "Profitability Ratio Monthly": profitability_ratio_monthly
    }

# Map phase type to functions
metric_functions = {
    "PHASE1": calculate_phase_metrics,
    "PHASE2": calculate_phase_metrics,
    "PHASE3": calculate_payout_metrics,
    "CHALLENGE": calculate_challenge_metrics,
    "FUNDED": calculate_funded_metrics
}

# ==========================
# SAVE METRICS TO CSV FILES
# ==========================

def save_metrics(group_name, metrics_dict, save_path):
    if not metrics_dict:
        print(f"No metrics found for {group_name}")
        return
    file_path = save_path / f"METRICS_{group_name}.csv"
    with open(file_path, "w", newline='', encoding='utf-16') as f:
        writer = csv.writer(f, delimiter='\t')
        first_metrics = next(iter(metrics_dict.values()))
        headers = list(first_metrics.keys())
        writer.writerow(headers)
        for filename, metrics in metrics_dict.items():
            row = list(metrics.values())
            writer.writerow(row)

# Scan each simulation folder
for folder in simulation_folders:
    grouped_metrics = {
        "PHASE1": {},
        "PHASE2": {},
        "PHASE3": {},
        "CHALLENGE": {},
        "FUNDED": {}
    }

    csv_files = list(folder.glob("*.csv"))

    for csv_path in csv_files:
        df = readCSV(csv_path)
        if df is None or df.empty:
            continue

        filename = csv_path.name.upper()

        if "PHASE1.CSV" in filename:
            metrics = calculate_phase_metrics(df)
            grouped_metrics["PHASE1"][csv_path.name] = metrics
        elif "PHASE2.CSV" in filename:
            metrics = calculate_phase_metrics(df)
            grouped_metrics["PHASE2"][csv_path.name] = metrics
        elif "PHASE3.CSV" in filename:
            metrics = calculate_payout_metrics(df)
            grouped_metrics["PHASE3"][csv_path.name] = metrics
        elif "CHALLENGE.CSV" in filename:
            metrics = calculate_challenge_metrics(df)
            grouped_metrics["CHALLENGE"][csv_path.name] = metrics
        elif "FUNDED.CSV" in filename:
            metrics = calculate_funded_metrics(df)
            grouped_metrics["FUNDED"][csv_path.name] = metrics
        else:
            print(f"Could not classify file: {csv_path}")
        
    # Save metrics after processing csv files
    metrics_folder = folder / "METRICS"
    metrics_folder.mkdir(exist_ok=True)

    for group_name in ["PHASE1", "PHASE2", "PHASE3", "CHALLENGE", "FUNDED"]:
        save_metrics(group_name, grouped_metrics.get(group_name, {}), metrics_folder)
        