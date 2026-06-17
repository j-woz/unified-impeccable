#!/usr/bin/env python3

import sys
import re
import argparse
from pathlib import Path
import numpy as np
from scipy.stats import pearsonr

"""
Example:

s4b-correlate.py /lus/flare/projects/IMPECCAFLOW/wozniak/IMPECCABLE/work-Medium-2b /lus/flare/projects/IMPECCAFLOW/wozniak/IMPECCABLE/work-Medium-2b/jobs/sub_p2_s4b-aurora_job-EX7.txt
"""


def main():
    args = parse_args()


    if not Path(args.directory).is_dir():
        raise IOException("not a directory: " + args.directory)

    metadata, tasks, label_to_lig = parse_log_file(args.log, args.directory, args.limit, args.minimum)
    print_summary(metadata, tasks)
    print_task_details(tasks, args.limit, args.minimum)
    compute_correlation(tasks, args.limit, args.minimum)


def parse_args():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description='Parse log file and correlate duration with PDB length'
    )
    parser.add_argument(
        'directory',
        help='Directory containing data files'
    )
    parser.add_argument(
        'log',
        help='Log file'
    )
    parser.add_argument(
        '--limit',
        type=int,
        default=10,
        help='Maximum number of duration lines to process (default: 10)'
    )
    parser.add_argument(
        '--minimum',
        type=float,
        default=0.0,
        help='Minimum duration in seconds; tasks below this are excluded (default: 0.0)'
    )

    return parser.parse_args()


class Task:
    def __init__(self, label, lig, duration=None):
        self.label = label
        self.duration = float(duration) if duration is not None else None
        self.lig = lig
        self.pdb_lines = None

    def __repr__(self):
        return f"Task(label='{self.label}', duration={self.duration}, lig={self.lig}, lines={self.pdb_lines})"

    def __str__(self):
        return f"Task {self.label:>10s}  duration: {self.duration:7.2f}  lig: {self.lig:4d}  PDB: {self.pdb_lines:4d}"



def count_lines(file_path):
    """Count the number of lines in a file."""
    try:
        with open(file_path, 'r') as f:
            return sum(1 for _ in f)
    except (FileNotFoundError, IOError):
        return None


def parse_log_file(log_path, directory, limit=None, minimum=0.0):
    """Parse a step4b Aurora log file and extract task durations and lig mappings."""

    if not Path(log_path).exists():
        print(f"Error: File not found: {log_path}", file=sys.stderr)
        sys.exit(1)

    label_to_task = {}
    metadata = {}
    duration_count = 0

    with open(log_path, 'r') as f:
        for line_num, line in enumerate(f, 1):
            line = line.rstrip('\n')

            # Check if we've reached the limit
            if limit is not None and duration_count >= limit:
                break

            # Extract metadata from header lines
            if line.startswith('JOB:'):
                metadata['job_id'] = line.split(':', 1)[1].strip()

            # Extract exec lines: "app: <rank>:<sequence> exec: p2_s4b_process.sh <lig> ..."
            if ' app: ' in line and 'exec:' in line:
                match = re.match(r'.*app:\s+(\d+:\d+)\s+exec:.*p2_s4b_process\.sh\s+(\d+)', line)
                if match:
                    label = match.group(1)
                    lig = int(match.group(2))
                    task = Task(label, lig)
                    label_to_task[label] = task

            # Extract duration lines: "app: <rank>:<sequence> duration: <value>"
            if ' app: ' in line and 'duration:' in line:
                match = re.match(r'.*app:\s+(\d+:\d+)\s+duration:\s+([\d.]+)', line)
                if match:
                    label = match.group(1)
                    duration = match.group(2)
                    if label not in label_to_task:
                        print(f"Error at line {line_num}: duration label '{label}' has no corresponding exec line", file=sys.stderr)
                        sys.exit(1)
                    task = label_to_task[label]
                    task.duration = float(duration)

                    # Only count tasks that meet minimum duration threshold
                    if task.duration >= minimum:
                        # Look up PDB file and count lines
                        pdb_path = Path(directory) / "step4" / "mem0" / "itr0" / "lig_confs" / str(task.lig) / "0.pdb"
                        if pdb_path.exists():
                            task.pdb_lines = count_lines(str(pdb_path))

                        duration_count += 1

    tasks = list(label_to_task.values())
    label_to_lig = {label: task.lig for label, task in label_to_task.items()}
    return metadata, tasks, label_to_lig


def print_summary(metadata, tasks):
    """Print a summary of the parsed log data."""
    print("=== Log Summary ===")
    print(f"Job ID: {metadata.get('job_id', 'N/A')}")
    print(f"Tasks Found: {len(tasks)}")
    print()


def print_task_details(tasks, limit=10, minimum=0.0):
    """Print details of tasks with durations, up to limit, filtering by minimum duration."""
    tasks_with_duration = [task for task in tasks if task.duration is not None and task.duration >= minimum]
    print(f"=== Tasks with Duration (first {limit}, minimum={minimum}) ===")
    for task in tasks_with_duration[:limit]:
        print(task)


def compute_correlation(tasks, limit=10, minimum=0.0):
    """Compute correlation coefficient between duration and PDB lines, filtering by minimum duration."""
    tasks_with_duration = [task for task in tasks if task.duration is not None and task.duration >= minimum]
    tasks_with_both = [task for task in tasks_with_duration if task.pdb_lines is not None]

    if len(tasks_with_both) < 2:
        print("\n=== Correlation Analysis ===")
        print(f"Not enough tasks with both duration and PDB line count ({len(tasks_with_both)}).")
        return

    durations = np.array([task.duration for task in tasks_with_both])
    pdb_lines = np.array([task.pdb_lines for task in tasks_with_both])

    correlation, p_value = pearsonr(durations, pdb_lines)

    print("\n=== Correlation Analysis ===")
    print(f"Tasks analyzed: {len(tasks_with_both)} (minimum duration: {minimum})")
    print(f"Pearson correlation coefficient: {correlation:.4f}")
    print(f"P-value: {p_value:.4f}")


if __name__ == '__main__':
    main()
