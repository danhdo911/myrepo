import csv
import argparse
from jinja2 import Template

def parse_optional(value):
    return value.strip() if value and value.strip() else None

def parse_list(value):
    return [v.strip() for v in value.split(';') if v.strip()] if value else []

def parse_ip_list(ip_string):
    return ['"%s"' % ip.strip() for ip in ip_string.split(';') if ip.strip()]

parser = argparse.ArgumentParser()
parser.add_argument("--template_file", required=True)
parser.add_argument("--data_file", required=True)
parser.add_argument("--output_file", required=True)
args = parser.parse_args()

# Load template
with open(args.template_file) as f:
    template = Template(f.read(), trim_blocks=True, lstrip_blocks=True)

# Read CSV
networks = []
with open(args.data_file) as f:
        reader = csv.DictReader(f)
        for row in reader:
            row['project_name'] = row.get('project_name').strip()
            row['network_name'] = row.get('network_name').strip()
            row['external_enabled'] = row.get('external_enabled', '').strip()
            row['network_type'] = parse_optional(row.get('network_type'))
            row['physical_network'] = parse_optional(row.get('physical_network'))
            row['segmentation_id'] = parse_optional(row.get('segmentation_id'))
            row['subnet_name'] = row.get('subnet_name').strip()
            row['subnet_cidr'] = row.get('subnet_cidr').strip()
            row['enable_dhcp'] = row.get('enable_dhcp', '').strip()
            row['dns_nameservers'] = parse_ip_list(row.get('dns_nameservers'))

            # Parse allocation pools (comma-separated pairs)
            if row.get('allocation_pools'):
                pools = []
                for pair in row['allocation_pools'].split(';'):
                    start, end = pair.split('-')
                    pools.append({
                        "allocation_pool_start": start.strip(),
                        "allocation_pool_end": end.strip()
                    })
                row['allocation_pools'] = pools
            else:
                row['allocation_pools'] = []

            networks.append(row)

# Render and write output
rendered = template.render(networks=networks)

# cleaned = "\n".join(line for line in rendered.splitlines() if line.strip())

with open(args.output_file, "w") as f:
    f.write(rendered)

print(f"Generated: {args.output_file}")
