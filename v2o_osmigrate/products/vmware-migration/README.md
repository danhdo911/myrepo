# vmware-migration

## Overview

Tooling that migrates virtual machines from VMware to OpenStack.

## Directory structure

This layout is fixed by project convention. Add subdirectories inside these
directories; never add a new directory at the top level of the sub-product.

| Directory | Contents |
| --- | --- |
| `docs/specs/` | Feature specifications |
| `docs/architecture/` | Architecture design and threat models |
| `docs/adr/` | Decision records (technical and architectural) |
| `docs/runbooks/` | Operational procedures and incident response |
| `docs/reports/` | Reports and deliverables submitted by the development partner |
| `apps/` | Frontend and client applications |
| `services/` | Backend services and APIs |
| `libs/` | Code shared within this sub-product |
| `contracts/` | API contracts and schema definitions |
| `infra/` | Infrastructure as code (Terraform, Kubernetes, Ansible, and similar) |
| `migration-tools/` | Contains supported VM migration tools, with each tool maintaining its own automation, configuration, infrastructure setup, and documentation. |
| `observability/` | Monitoring, alerting, and dashboard configuration |
| `tests/` | End-to-end, integration, and performance tests |

## Reports

Upload reports to `docs/reports/`. PDF, Office, and image files are expected
there, and `docs/reports/*.log` is exempted from the log-file ignore rule so
that log evidence can be attached.

The convention checker reads text only, so it cannot inspect the contents of
a PDF or an Office document. Check every report by eye before committing it:
no internal hostnames, no IP addresses, no screenshots of internal systems.
A passing check does not cover these files, and it says so in its output.

## Directories that are not used here

Three directories of the standard sub-product layout have been removed from
this repository. Do not recreate them; the convention checker reports any of
them as a violation.

| Directory | Why it was removed | What to do instead |
| --- | --- | --- |
| `operations/` | Operational records are not maintained by external development partners. | Nothing — it is out of scope here. |
| `data/` | No data pipeline or analytics work is in scope at this time. | Nothing — it is out of scope here. |
| `docs/decision-log/` | Decisions are recorded in issues and pull requests instead. | Record the decision in the issue or pull request where it was made. Use `docs/adr/` when it needs a durable record in the repository. |

If work genuinely needs one of them, raise it before adding the directory.

## Where existing code goes

Migration tooling developed outside this layout should be placed under the corresponding tool directory in `migration-tools/`.

| Existing content | Destination |
| --- | --- |
| Migration tool implementation | `migration-tools/<tool>/` |
| Tool-specific documentation and KBs | `migration-tools/<tool>/docs/` |
| Tool-specific tests and validation | `migration-tools/<tool>/tests` |
| Shared Python helper functions and modules | `libs/` |

Before moving anything in, read the sensitive-data rules in the repository
root `README.md`. Real hostnames, IP addresses, and certificates must be
replaced with placeholders first.

## Quick Start

Select a migration tool and follow its tool-specific setup and migration instructions:

| Migration Tool | Documentation |
| --- | --- |
| Red Hat os-migrate | [`migration-tools/osmigrate/README.md`](./migration-tools/osmigrate/README.md) |
