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

bindings = []
with open(args.data_file) as f:
    reader = csv.DictReader(f)
    for row in reader:
        bindings.append({
            "binding_name": row["binding_name"],
            "binding_type": row.get("binding_type", "IPV4").strip().upper(),
            "network_name": row["network_name"],
            "ip_address": row.get("ip_address"),
            "mac_address": row.get("mac_address").strip().lower(),
            "dns_servers": parse_ip_list(row["dns_servers"]),
            "description": row.get("description", ""),
        })

rendered = template.render(bindings=bindings)

with open(args.output_file, "w") as f:
    f.write(rendered)

print(f"Generated: {args.output_file}")
