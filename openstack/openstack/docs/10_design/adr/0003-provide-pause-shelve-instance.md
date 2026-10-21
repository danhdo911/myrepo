# [HIGIO-0003] Provide Pause/Shelve/Suspend Instance Features for Tenants

* Status: Reviewed
* Deciders: Kurihara, Nguyen Don Bao Tran, Phan Minh Nhut, Nguyen Van Hau
* Date: [2026-08-24]

## Context and Problem Statement

* Context:
  * Tenants require the ability to temporarily stop or suspend virtual machines (VMs) without permanently deleting the instances.
  * OpenStack provides multiple instance lifecycle operations, including:
    * Pause
    * Shelve
    * Suspend
  * Pause, Shelve and Suspend have different resource and storage behaviors and should be exposed according to the intended tenant use cases.
  * The cloud platform needs to provide tenant self-service while maintaining predictable resource utilization and billing behavior.
  
* Problem Statement:
  * Tenants may need to temporarily stop workloads without deleting the VM.
  * Keeping unused VMs running consumes CPU and RAM resources even when the workload is temporarily inactive.
  * Long-term inactive instances may unnecessarily occupy compute resources.
  * Tenants need a self-service mechanism to temporarily release compute resources while preserving the VM configuration and workload state.
  * Without Pause/Shelve/Suspend functionality, tenants may need administrator assistance or delete/recreate instances, increasing operational overhead.
  * Different lifecycle states may have different billing implications and must be clearly defined.

## Decision Drivers

* Provide tenant self-service for temporary VM suspension.
* Reduce unnecessary CPU and RAM consumption for inactive workloads.
* Preserve the instance configuration and attached resources where possible.
* Support short-term and long-term workload suspension scenarios.
* Maintain compatibility with native OpenStack instance lifecycle operations.
* Provide clear and predictable billing behavior.
* Minimize operational overhead for cloud administrators.

## Considered Options

1. Provide Pause functionality to tenants.
2. Provide Shelve functionality to tenants.
3. Provide Suspend functionality to tenants.

## Decision Outcome

**Do Not Choose Options 1, 2, or 3: Do Not Provide These Functionalities to Tenants**.

Theses actions such as **Pause / Suspend / Shelve** ultimately serve a similar purpose: customers want to stop their VMs and release compute resources (**RAM/CPU**)

* Tenants will simply use **Stop VM**, which is sufficient for this use case.
* When a VM is stopped, **RAM/CPU resources are released**, while **disk resources remain allocated and continue to be charged**.
* This approach (Stop VMs) keeps VM state management simpler for tenants while still meeting the main requirement.
* **Pause/Shelve** cannot support the use case where a customer wants to preserve the VM's memory state while stopping CPU/RAM charges. **Suspend** would meet this requirement functionally, but we cannot provide it due to infrastructure operational constraints.

## Pros and Cons of the Options <!-- optional -->

### Option 1: Provide Pause

* Good, Simple tenant experience.
* Good, Supports short-term workload suspension.
* Good, VM state can be preserved for quick resume.
* Good, Minimal change to the existing tenant lifecycle model.
* Good, Paused instances may continue occupying compute resources.
* Bad, Not suitable for long-term suspension.
* Bad, Limited resource optimization.
* Bad, Tenants cannot release compute resources while preserving * the instance for later use.
* Bad, May result in unnecessary CPU/RAM resource consumption.

### Option 2: Provide Shelve

* Good, Releases compute resources when the VM is shelved.
* Good, Suitable for long-term workload suspension.
* Good, Reduces unnecessary CPU/RAM consumption.
* Good, Tenant can later unshelve the instance.
* Good, Better resource efficiency for inactive workloads.
* Bad, Less suitable for short-term suspension where fast resume is required.
* Bad, Unshelve requires additional operations to restore the instance to a compute host.
* Bad, Additional storage operations may be required depending on the configured shelve behavior.
* Bad, More complex billing and lifecycle-state management.

### Option 3: Provide Suspend

* Good, Releases compute resources when the VM is Suspended
* Good, Suitable for long-term workload suspension.
* Good, Reduces unnecessary CPU/RAM consumption.
* Good, Tenant can later resume the instance.
* Good, Better resource efficiency for inactive workloads.
* Bad, The VM memory state is written to disk on the compute host. For instances with large amounts of RAM, suspending many VMs can consume significant local disk space.
* Bad, If local disk space becomes exhausted, additional suspend operations or other compute workloads may fail.
