import json
from jinja2 import Template
import argparse

parser = argparse.ArgumentParser(description="Generate Ansible inventory from Terraform output JSON.")
parser.add_argument("--input-file", "-i",required=True,help="Path to the Terraform JSON output file (e.g., vms_info.json)")
parser.add_argument("--output-file", "-o",required=True,help="Path to save the rendered Ansible inventory file")
parser.add_argument("--template-file", "-t",default="inventory.j2",help="Path to the Jinja2 template file (default: inventory.j2)")
args = parser.parse_args()

with open(args.input_file) as f:
    vms = json.load(f)

with open(args.template_file) as f:
    template = Template(f.read())

output = template.render(vms=vms)

with open(args.output_file, "w") as f:
    f.write(output)
