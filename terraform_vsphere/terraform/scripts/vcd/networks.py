import csv
import argparse
from jinja2 import Template

# Parse command-line arguments
parser = argparse.ArgumentParser(description="Generate Terraform config from Jinja2 and CSV")
parser.add_argument("--template_file", required=True, help="Path to the Jinja2 template file")
parser.add_argument("--data_file", required=True, help="Path to the CSV file with data")
parser.add_argument("--output_file", required=True, help="Output .tf file path")
args = parser.parse_args()

# Load the template
with open(args.template_file) as tpl_file:
    template = Template(tpl_file.read())

modules = []

# Read CSV and render template for each row
with open(args.data_file) as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        modules.append(template.render(**row))

# Write all rendered modules into the output file
with open(args.output_file, "w") as tf_file:
    tf_file.write("\n\n".join(modules))

print(f"Generated: {args.output_file}")
