import csv
import argparse
from jinja2 import Template

def parse_optional(value):
    return value.strip() if value and value.strip() else None

def parse_list(value):
    return [v.strip() for v in value.split(';') if v.strip()] if value else []

parser = argparse.ArgumentParser()
parser.add_argument("--template_file", required=True)
parser.add_argument("--data_file", required=True)
parser.add_argument("--output_file", required=True)
args = parser.parse_args()

# Load template
with open(args.template_file) as f:
    template = Template(f.read(), trim_blocks=True, lstrip_blocks=True)

# Read CSV
rules = []
with open(args.data_file) as f:
    reader = csv.DictReader(f)
    for row in reader:
        rules.append({
            "rule_name": row["rule_name"],
            "rule_type": row["rule_type"].strip().upper(),
            "description": row.get("description", ""),
            "external_address": row["external_address"],
            "internal_address": row["internal_address"],
            "app_port_profile_id": parse_optional(row.get("app_port_profile_name")),
            "scope": row.get("port_profile_scope", "").strip().upper(),
            "dnat_external_port": parse_optional(row.get("dnat_external_port")),
            "snat_destination_address": parse_optional(row.get("snat_destination_address")),
            "enabled_logging": row.get("enabled_logging", "false"),
            "firewall_match": row.get("firewall_match", "MATCH_INTERNAL_ADDRESS"),
            "priority": row.get("priority", "")
        })

# Render and write output
rendered = template.render(rules=rules)

cleaned = "\n".join(line for line in rendered.splitlines() if line.strip())

with open(args.output_file, "w") as f:
    f.write(cleaned)

print(f"Generated: {args.output_file}")
