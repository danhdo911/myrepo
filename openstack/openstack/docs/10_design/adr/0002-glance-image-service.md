# [HIGIO-0002] Glance image Service

* Status: Accepted
* Deciders: Kurihara, Okizaki, Nguyen Don Bao Tran, Phan Minh Nhut, Nguyen Van Hau, Operation Team 
* Date: [2026-07-16]

## Context and Problem Statement

* Context: Centralized Image Management And Private Image Self Service
  - Support for Multiple OS Image Types
  - Virtual machine image formats:
    - ISO
    - QCOW2
  
* Problem Statement: Managing VM images independently for each tenant introduces several operational, challenges:
  - Image duplication
  - Increased storage consumption
  - Complex quota management
  - Higher risk of storage exhaustion due to uncontrolled tenant image uploads.
  - Increased bandwidth utilization when multiple tenants upload large images simultaneously. Potential network congestion during concurrent image uploads.

## Decision Drivers

Glance provides a centralized image repository and Private Image Self Service for the entire OpenStack cloud.
* Public images can be shared across all tenants.
* All tenants deploy virtual machines from the same validated and approved golden images.
* Consistent operating system versions and configurations.
* Simplified image lifecycle management.
* Tenants require customized operating system images.
* Tenants are charged for their own image storage consumption.

## Considered Options

 1. Centralized Image Management
 2. Centralized Image Management And Private Image Self Service

## Decision Outcome

Choose Option 2: Centralized Image Management and Private Image Self Service, because:
* It follows the same image catalog concept as VMware Cloud Director (VCD).
* Tenants are charged for their own image storage consumption.
* Public images can be shared across all tenants.
* Tenants require customized operating system images.
* Sufficient storage capacity is available.
* Supports quota management.
* Acknowledge the risk
* The operations team has experience in customer service

## Pros and Cons of the Options <!-- optional -->

### 1: Centralized Image Management

Good, Single repository for approved operating system images.
Good, Eliminates duplicate images.
Good, Reduces storage consumption.
Good, Ensures consistent operating system versions.
Good, Reduces administrative overhead.
Bad, Tenants cannot upload their own operating system images.
Bad, Custom image requests require administrator support.
Bad, Less flexibility for specialized workloads.
Bad, Prohibiting image uploads will restrict other functions as well (Example: Creating an instance snapshot requires permission to upload an image).

### 2: Centralized Image Management and Private Image Self Service

Good, Single repository for approved operating system images.
Good, Allows tenants to manage their own images.
Good, Supports custom operating system and application images.
Good, Tenants are charged for their own image storage consumption.
Bad, Image duplication across tenants.
Bad, Higher storage consumption.
Bad, More complex quota management.
Bad, Higher administrative overhead to support customers.