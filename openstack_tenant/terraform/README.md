#

## Descriptions

- Terraform: provisioning
  - virtual machines
  - vcenter appliance
  - vcd appliance
  - nsx managers
  - nsx edge node

## Directories Structure (vCD)

```plaintext
terraform
├──templates/                       # Templates for config generation
├──scripts/                         # Scripts (bash, python, etc.)
├──modules/                         # Terraform modules
├──projects/
│   ├── g1_migration_vcdconfig/     # Project name
│   ├── *.tf                        # Shared logic (providers, data sources, defaults)
│   │   └── environments   
│   │   │   ├── tenant_A/           # Specify Tenant's input configurations
│   │   │   │   ├── csv_data/      
│   │   │   │   └── states/        
│   │   │   │   ├── *.tfvars       
│   │   │   ├── tenant_B/
│   │   │   └── ...
│   ├── nsxconfig/
│   ├── *.tf
│   │   └── environments 
│   │   │   ├── tenant_X/
│   └── ...
```

## Service Account Permissions

- The service account could create and configure settings: Networks, IP Set, Custom Application Port Profiles, NAT and Firewall rules.

```yaml
ACCESS CONTROL
    Organization
        View:
        Allow Access to All Organization VDCs
        View Organization Networks
COMPUTE
    Organization VDC
        View:
        View Compute Policies for an Organization VDC
        View Organization VDCs
NETWORKING
    Edge Gateway
        View:
        View Gateway
    Edge Gateway Services
        Manage:
        DHCP Configure
        Firewall Configure
        NAT Configure
    Organization VDC Network
        Manage:
        Edit Properties
```
