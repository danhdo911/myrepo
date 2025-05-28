import sys
import os
import csv
import argparse

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from functions.parse_optional import parse_strip, parse_list, parse_ip_list
from functions.load_template import load_template

def gen_project_csv(file_path):
    projects = []
    with open(file_path, newline='') as f:
        reader = csv.DictReader(f)
        for row in reader:
            project = {
                "project_name": parse_strip(row.get("project_name")).upper(),
                "domain": parse_strip(row.get("domain")),
                "descriptions": row.get("descriptions", "")
            }
            projects.append(project)
    return projects

def gen_network_csv(file_path):
    networks_map = {}
    with open(file_path, newline='') as f:
            reader = csv.DictReader(f)
            for row in reader:
                key = (
                    parse_strip(row.get("project_name")).upper(),
                    parse_strip(row.get("network_name"))
                )

                subnet = {
                    "network_name": parse_strip(row.get("network_name")),
                    "subnet_name": parse_strip(row.get("subnet_name")),
                    "subnet_cidr": parse_strip(row.get("subnet_cidr")),
                    "enable_dhcp": parse_strip(row.get("enable_dhcp", "")),
                    "allocation_pools": row["allocation_pools"],
                    "dns_nameservers": parse_ip_list(row.get("dns_nameservers"))
                }
                
                # Parse allocation pools (comma-separated pairs)
                if row.get("allocation_pools"):
                    pools = []
                    for pair in parse_list(row["allocation_pools"]):
                        if "-" in pair:
                            start, end = pair.split("-")
                            pools.append({
                                "allocation_pool_start": parse_strip(start),
                                "allocation_pool_end": parse_strip(end)
                            })
                    subnet["allocation_pools"] = pools
                else:
                    subnet["allocation_pools"] = []
                
                if key not in networks_map:
                    networks_map[key] = {
                        "project_name": key[0],
                        "network_name": key[1],
                        "external_enabled": parse_strip(row.get("external_enabled", "")),
                        "network_type": parse_strip(row.get("network_type")),
                        "physical_network": parse_strip(row.get("physical_network")),
                        "segmentation_id": parse_strip(row.get("segmentation_id")),
                        "subnets": []
                    }

                networks_map[key]["subnets"].append(subnet)
    return list(networks_map.values())

def gen_router_csv(file_path):
    routers = []
    with open(file_path, newline='') as f:
            reader = csv.DictReader(f)
            for row in reader:
                router = {
                    "project_name": parse_strip(row.get("project_name")).upper(),
                    "router_name": parse_strip(row.get("router_name")),
                    "external_network": parse_strip(row.get("external_network")),
                    "external_subnet": parse_strip(row.get("external_subnet")),
                    "external_ip_address": parse_strip(row.get("external_ip_address")),
                    "local_network": parse_strip(row.get("local_network")),
                    "local_subnet": parse_strip(row.get("local_subnet"))
                }
                routers.append(router)
    return routers


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--template_dir", required=True, help="Directory containing template files")
    parser.add_argument("--data_dir", required=True, help="Directory containing CSV data files")
    parser.add_argument("--output_file", required=True, help="Path to output .tf file")
    args = parser.parse_args()

    # Paths
    project_csv = os.path.join(args.data_dir, "project.csv")
    network_csv = os.path.join(args.data_dir, "network.csv")
    router_csv = os.path.join(args.data_dir, "router.csv")

    project_tpl = os.path.join(args.template_dir, "project.tftpl")
    network_tpl = os.path.join(args.template_dir, "network.tftpl")
    router_tpl = os.path.join(args.template_dir, "router.tftpl")

    # Load templates
    tpl_project = load_template(project_tpl)
    tpl_network = load_template(network_tpl)
    tpl_router = load_template(router_tpl)

    # Load CSV data
    project = gen_project_csv(project_csv)
    networks = gen_network_csv(network_csv)
    routers = gen_router_csv(router_csv)

    # Render
    rendered_project = tpl_project.render(projects=project)
    rendered_network = tpl_network.render(networks=networks)
    rendered_router = tpl_router.render(routers=routers)

    combined_render = "\n".join([rendered_project, rendered_network, rendered_router])

    # Save output
    with open(args.output_file, "w") as f:
        f.write(combined_render)

    print(f"Generated: {args.output_file}")
