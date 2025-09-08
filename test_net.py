#!/bin/python3
import statistics
import speedtest

def run_speedtest(trials=5):
    download_speeds = []
    upload_speeds = []
    latencies = []

    for i in range(trials):
        print(f"Trial {i+1}/{trials}...")

        st = speedtest.Speedtest()
        st.get_best_server()  # automatically picks lowest-latency server

        # Measure latency
        latency = st.results.ping  # ms
        latencies.append(latency)

        # Measure throughput
        download = st.download() / 1e6  # bits/s -> Mbit/s
        upload = st.upload() / 1e6

        download_speeds.append(download)
        upload_speeds.append(upload)

        print(f"  Latency: {latency:.2f} ms | Download: {download:.2f} Mbps | Upload: {upload:.2f} Mbps")

    return latencies, download_speeds, upload_speeds


def summarize(name, values, unit):
    print(f"\n{name} ({unit}):")
    print(f"  Mean:   {statistics.mean(values):.2f}")
    print(f"  Median: {statistics.median(values):.2f}")
    print(f"  Stdev:  {statistics.pstdev(values):.2f}")
    print(f"  Min:    {min(values):.2f}")
    print(f"  Max:    {max(values):.2f}")


if __name__ == "__main__":
    trials = 5  # increase if you want more stability
    latencies, downloads, uploads = run_speedtest(trials)

    summarize("Latency", latencies, "ms")
    summarize("Download throughput", downloads, "Mbps")
    summarize("Upload throughput", uploads, "Mbps")

