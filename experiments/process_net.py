#!/bin/python3
import os
import json
import pandas as pd
import matplotlib.pyplot as plt

folder_path = "./network"  # your folder containing JSON files

results = {}

# Load all JSON files
for filename in os.listdir(folder_path):
    if filename.endswith(".json"):
        filepath = os.path.join(folder_path, filename)
        with open(filepath, "r") as f:
            data = json.load(f)
        if "trials" in data:
            df = pd.DataFrame(data["trials"])
            results[filename] = df

if not results:
    raise ValueError("No JSON files with 'trials' found in the folder.")

# Plotting
fig, axs = plt.subplots(3, 1, figsize=(10, 12), sharex=True)

for filename, df in results.items():
    axs[0].plot(df["trial"], df["latency_ms"], marker='o', label=filename)
    axs[1].plot(df["trial"], df["download_mbps"], marker='o', label=filename)
    axs[2].plot(df["trial"], df["upload_mbps"], marker='o', label=filename)

# Set labels and titles
axs[0].set_ylabel("Latency (ms)")
axs[0].set_title("Latency per Trial")
axs[0].legend()

axs[1].set_ylabel("Download (Mbps)")
axs[1].set_title("Download Throughput per Trial")
axs[1].legend()

axs[2].set_ylabel("Upload (Mbps)")
axs[2].set_title("Upload Throughput per Trial")
axs[2].set_xlabel("Trial Number")
axs[2].legend()

plt.tight_layout()
plt.show()

