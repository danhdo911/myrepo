import argparse
import json
import os
import sys
import yaml


# Add the python/ directory to Python's module search path.
PYTHON_ROOT = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..")
)

sys.path.insert(0, PYTHON_ROOT)

from functions.vm_filter import filter_vms


def parse_args():
    parser = argparse.ArgumentParser(
        description="Check VM readiness from inventory JSON."
    )

    parser.add_argument(
        "--input-file",
        default="../output/vm_data_extra_info.json",
        help="Path to the VM inventory JSON file.",
    )

    parser.add_argument(
        "--output-file",
        default="../output/vm_data_readiness.json",
        help="Path to the readiness-check output JSON file.",
    )

    parser.add_argument(
        "--config",
        default="../readiness_requirements.yml",
        help="Path to the readiness requirements file.",
    )

    return parser.parse_args()


def load_json(file_path):
    if not os.path.isfile(file_path):
        raise FileNotFoundError(
            f"Input file does not exist: {file_path}"
        )

    with open(file_path, "r", encoding="utf-8") as json_file:
        return json.load(json_file)


def save_json(file_path, data):
    absolute_path = os.path.abspath(file_path)

    os.makedirs(os.path.dirname(absolute_path), exist_ok=True)

    with open(absolute_path, "w", encoding="utf-8") as file:
        json.dump(data, file, indent=2)

    return absolute_path

def load_config(file_path):
    with open(file_path, "r", encoding="utf-8") as file:
        return yaml.safe_load(file)
    
def main():
    args = parse_args()

    config = load_config(args.config)
    vm_data = load_json(args.input_file)
    ready, not_ready = filter_vms(vm_data, config)

    ready_path = save_json(args.output_file, ready)

    not_ready_path = save_json(
        args.output_file.replace(".json", "_not_ready.json"),
        not_ready
    )

    total_vms = len(vm_data)
    ready_vms = len(ready)
    not_ready_vms = len(not_ready)

    print(f"\nSource inventory: {os.path.abspath(args.input_file)}")
    print("\nReadiness Summary")
    print(f"  Total VMs     : {total_vms}")
    print(f"  Ready VMs     : {ready_vms}")
    print(f"  Not Ready VMs : {not_ready_vms}")
    print()
    print(f"  Ready inventory: {ready_path}")
    print(f"  Not ready inventory: {not_ready_path}")
    print()
    
if __name__ == "__main__":
    main()