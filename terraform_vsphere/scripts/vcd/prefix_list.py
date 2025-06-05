import csv
import os
from jinja2 import Environment, FileSystemLoader
from collections import defaultdict

import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--template_file", required=True)
parser.add_argument("--data_file", required=True)
parser.add_argument("--output_file", required=True)
args = parser.parse_args()

# Load Jinja2 template
env = Environment(loader=FileSystemLoader(os.path.dirname(args.template_file)))
template = env.get_template(os.path.basename(args.template_file))

# Group rows by prefix_list_name
modules_dict = defaultdict(list)
meta_info = {}

with open(args.data_file, newline="") as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        name = row["prefix_list_name"]
        modules_dict[name].append({
            "action": row["action"],
            "network": row.get("network", ""),
            "le": row.get("le", ""),
            "ge": row.get("ge", ""),
        })

        if name not in meta_info:
            meta_info[name] = {
                "prefix_list_name": name,
                "description": row.get("description", ""),
                "scope": row.get("scope", ""),
                "tag": row.get("tag", "")
            }

# Merge for rendering
modules = []
for name, prefixes in modules_dict.items():
    m = meta_info[name]
    m["prefixes"] = prefixes
    modules.append(m)


rendered = template.render(modules=modules)

cleaned = "\n".join(line for line in rendered.splitlines() if line.strip())


# Render and save
with open(args.output_file, "w") as f:
    f.write(cleaned)

print(f"✅ All modules written to {args.output_file}")
