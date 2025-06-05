import json
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--input-file", required=True)
parser.add_argument("--output-file", required=True)
args = parser.parse_args()

# Load Terraform output from JSON file
with open(args.input_file) as f:
    data = json.load(f)

with open(args.output_file, "w") as inv_file:
    # Group: [all]
    inv_file.write("[all]\n")
    # Inventory
    for vm_id, vm_info in data.items():
        ip = vm_info["networks"][0]["ip_address"].split("/")[0]
        name = vm_info.get("name", vm_id)
        line = f"{name} ansible_host={ip}\n"
        print(line.strip())  # Print to stdout
        inv_file.write(line)
    inv_file.write("\n")
    
    # Group variables
    inv_file.write("[all:vars]\n")
    inv_file.write("ansible_user=ubuntu\n")
    inv_file.write("ansible_ssh_private_key_file=~/.ssh/iij_danhdo\n")
