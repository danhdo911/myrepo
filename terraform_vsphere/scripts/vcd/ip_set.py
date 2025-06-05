import csv
import argparse
from jinja2 import Template

def parse_ip_list(ip_string):
    return ['"%s"' % ip.strip() for ip in ip_string.split(';') if ip.strip()]

# Parse command-line arguments
parser = argparse.ArgumentParser(description="Generate Terraform config from Jinja2 and CSV")
parser.add_argument("--template_file", required=True, help="Path to the Jinja2 template file")
parser.add_argument("--data_file", required=True, help="Path to the CSV file with data")
parser.add_argument("--output_file", required=True, help="Output .tf file path")
args = parser.parse_args()

with open(args.template_file) as f:
    template = Template(f.read(), trim_blocks=True, lstrip_blocks=True)

ip_sets = []
with open(args.data_file) as f:
    reader = csv.DictReader(f)
    for row in reader:
        ip_sets.append({
            "ip_set_name": row["ip_set_name"],
            "ip_set_description": row.get("ip_set_description", ""),
            "ip_set_subnets": parse_ip_list(row["ip_set_subnets"])
        })

rendered = template.render(ip_sets=ip_sets)

with open(args.output_file, "w") as f:
    f.write(rendered)

print(f"Generated: {args.output_file}")
