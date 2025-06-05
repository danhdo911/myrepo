import csv
import argparse
from jinja2 import Template

def parse_port_list(port_string):
    return ['"%s"' % p.strip() for p in port_string.split(';') if p.strip()]

parser = argparse.ArgumentParser()
parser.add_argument("--template_file", required=True)
parser.add_argument("--data_file", required=True)
parser.add_argument("--output_file", required=True)
args = parser.parse_args()

with open(args.template_file) as f:
    template = Template(f.read(), trim_blocks=True, lstrip_blocks=True)

profiles = []
with open(args.data_file) as f:
    reader = csv.DictReader(f)
    for row in reader:
        profiles.append({
            "port_profile_name": row["port_profile_name"],
            "port_profile_description": row.get("port_profile_description", ""),
            "port_protocol": row["port_protocol"].strip().upper() or "TCP",
            "port_app": parse_port_list(row["port_app"])
        })

rendered = template.render(profiles=profiles)

with open(args.output_file, "w") as f:
    f.write(rendered)

print(f"Generated: {args.output_file}")
