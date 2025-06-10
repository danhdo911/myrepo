#!/bin/bash

PROJECTS="g1_migration_vcdconfig_ipset"
TENANT_PATH=$1
MODULES=$2

# Base directories
TEMPLATE_DIR="../../templates/vcd"
CSV_DIR="../../projects/$PROJECTS/environments/$TENANT_PATH/csv_data"
OUTPUT_DIR="../../projects/$PROJECTS"

# Help and usage
if [[ -z "$2" || "$1" == "-h" || "$1" == "--help" ]]; then
    echo "❌ Usage: $0 <tenant_path> <modules|--all>"
    echo "Modules: networks, network_dhcp_binding, ip_set, app_port_profiles, nat_rules, firewall_rules"
    echo "Example: $0 tenant_A networks,ip_set"
    echo "Example: $0 tenant_A --all"
    exit 1
fi

# For run generate all modules
ALL_MODULES="networks,network_dhcp_binding,ip_set,app_port_profiles,nat_rules,firewall_rules"

if [[ "$MODULES" == "--all" ]]; then
    MODULES=$ALL_MODULES
fi

# Convert comma-separated module list to array
IFS=',' read -r -a MODULE_ARRAY <<< "$MODULES"

# Loop through each module in the array
for MODULE in "${MODULE_ARRAY[@]}"; do
    TEMPLATE_FILE="${TEMPLATE_DIR}/${MODULE}.tftpl"
    CSV_FILE="${CSV_DIR}/${MODULE}.csv"
    OUTPUT_FILE="${OUTPUT_DIR}/0_${MODULE}.tf"

    if [[ -f "$TEMPLATE_FILE" && -f "$CSV_FILE" ]]; then
        echo "✅ Generating for module: $MODULE"
        python3 $MODULE.py \
            --template_file "$TEMPLATE_FILE" \
            --data_file "$CSV_FILE" \
            --output_file "$OUTPUT_FILE"
    else
        echo "⚠️  Skipping $MODULE — template or CSV missing."
        echo "→ Precheck these files in $TEMPLATE_DIR or $CSV_DIR"
    fi
done

###
echo "#####################################"
echo "🧹 Running terraform fmt..."
cd $OUTPUT_DIR && terraform fmt
