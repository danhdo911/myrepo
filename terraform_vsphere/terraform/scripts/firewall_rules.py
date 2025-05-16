import csv
import argparse
from jinja2 import Template

def parse_list(value):
    return [v.strip() for v in value.split(';')] if value else []

parser = argparse.ArgumentParser()
parser.add_argument("--template_file", required=True)
parser.add_argument("--data_file", required=True)
parser.add_argument("--output_file", required=True)
args = parser.parse_args()

with open(args.template_file) as f:
    template = Template(f.read())

rules = []
with open(args.data_file) as f:
    reader = csv.DictReader(f)
    for row in reader:
        rules.append({
            "name": row["name"],
            "direction": row["direction"],
            "ip_protocol": row["ip_protocol"],
            "action": row["action"],
            "source_ids": parse_list(row["source_ids"]),
            "destination_ids": parse_list(row["destination_ids"]),
            "type": row["type"].strip(),
            "app_port_profile_ids": parse_list(row.get("app_port_profile_name", "")),
            "scope": row.get("port_profile_scope", "").strip()
        })

rendered = template.render(rules=rules)

cleaned = "\n".join(line for line in rendered.splitlines() if line.strip())

with open(args.output_file, "w") as f:
    f.write(cleaned)

print(f"Generated: {args.output_file}")
