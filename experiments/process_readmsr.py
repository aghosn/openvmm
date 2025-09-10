#!/bin/python3
import json
import matplotlib.pyplot as plt

# Load JSON data
with open("readmsr/results.json", "r") as f:  # replace with your filename
    data = json.load(f)

labels = list(data.keys())
values = list(data.values())
colors = ['#1f77b4', '#ff7f0e', '#2ca02c']  # different color for each bar

# Plot
plt.figure(figsize=(6, 4))
bars = plt.bar(labels, values, color=colors)

# Set log scale for Y-axis
plt.yscale('log')

# Add value labels on top
for bar in bars:
    height = bar.get_height()
    plt.text(bar.get_x() + bar.get_width()/2, height * 1.05, f'{height:.2f}', ha='center', va='bottom')

plt.ylabel("Time per rdmsr (µs) [log scale]")
plt.title("Microseconds per rdmsr Operation")
plt.tight_layout()
plt.show()

