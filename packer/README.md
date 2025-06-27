#

## Requirements

- Packages: docker, docker-compose
- Docker Image: harbor.iij.com.vn/customized-images/packer_vault:1.0
- ISO: Ubuntu 22.04.5 (on vCenter)

## Directories Structure

```bash
.
├── 001-ubuntu-2204-basic
├── 002-ubuntu-2204                 # Template configurations
│   ├── cloud-init
│   │   ├── meta-data
│   │   └── user-data
│   ├── ubuntu-2204.pkr.hcl
│   └── variables.pkr.hcl
├── Dockerfile
├── Makefile
├── README.md
├── docker-compose.yml
├── environments
│   ├── dev                         # ENV configurations
│   │   └── template.pkrvars.hcl
│   ├── lab199
│   │   └── template.pkrvars.hcl
│   └── ...
└── scripts
    └── setup-script.sh

```

## Makefile

- Using makefile to run deployment tasks.

```bash
# Packer init
make init ENV=<environment>

# Packer validate
make validate ENV=<environment>

# Packer build image
make image ENV=<environment>
```
