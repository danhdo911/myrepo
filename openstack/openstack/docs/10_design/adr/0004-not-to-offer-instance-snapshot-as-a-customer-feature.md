# [HIGIO-0004] Do Not Offer Instance Snapshot as a Customer Feature

* Status: Reviewed
* Deciders: Kurihara, Phan Minh Nhut, Nguyen Van Hau, Operation Team
* Date: [2026-10-05]

## Context and Problem Statement

* Context:
  * Openstack provides an **Instance Snapshot** capability through Nova. The term "snapshot" can create an expectation that the feature behaves similarly to the VM snapshot functionality commonly used in VMware environments.
  * In VMware, users commonly understand a VM snapshot as a point-in-time snapshot associated with an existing virtual machine. It can be used as a temporary rollback point before activities such as:
    * Operating system upgrades
    * Application upgrades
    * Configuration changes
    * Patching
  * Openstack Instance Snapshot does **not provide the same operational model**. An Openstack Instance Snapshot primarily captures the instance disk state and creates an image. The resulting object is managed as an image rather than as a rollback point directly attached to the lifecycle of the original instance.

* Problem Statement:
  * If Openstack Instance Snapshot is exposed as a customer-facing feature, the term **"Instance Snapshot" may create incorrect expectations for customers familiar with VMware snapshot functionality**.
  * A customer may assume that creating an Instance Snapshot provides a temporary point-in-time rollback mechanism for the existing VM. This expectation does not accurately represent the Openstack Instance Snapshot workflow.

## Decision Drivers

* **Customer Expectation:** Customers familiar with VMware may expect Instance Snapshot to provide VMware-style snapshot and rollback functionality.
* **User Experience:**  Customer-facing features should have behavior that is clear and predictable from the customer's perspective.
* **Service Clarity:** The platform should avoid exposing functionality whose terminology may imply capabilities that are not actually provided.
* **Platform Consistency:** Features exposed through the customer portal should have clearly defined workflows and expected outcomes.

## Considered Options

1. Offer Instance Snapshot as a Customer Feature
2. Do Not Offer Instance Snapshot as a Customer Feature

## Decision Outcome

**Option 2 — Do Not Offer Instance Snapshot as a Customer Feature.**

Openstack Instance Snapshot will not be exposed as a standard customer-facing feature.

* The primary reason is the **functional and expectation mismatch between Openstack Instance Snapshot and the VM snapshot behavior commonly expected by customers familiar with VMware**.
* Openstack Instance Snapshot therefore should not be presented as a direct **VM rollback capability**.
* The feature may remain available internally for controlled administrative or operational use where its actual behavior is understood.

## Pros and Cons of the Options <!-- optional -->

### Option 1: Offer Instance Snapshot as a Customer Feature

* Good, Provides a native Openstack feature for creating an image from an existing instance.
* Good, Allows customers to create a copy of an instance for future use.
* Good, Supports image-based workflows, such as creating new instances from the captured image.
* Bad, The term **"Snapshot"** may be misunderstood as a VMware-style snapshot.
* Bad, Customers may expect to restore or roll back the running instance directly to the snapshot.
* Bad, Customers may expect a **"Revert to Snapshot"** function, which is not the intended use.
* Bad, Customers may expect multiple restore points or snapshot trees.
* Bad, Customers may use Instance Snapshot as a backup or rollback mechanism before system changes.

### Option 2 — Do Not Offer Instance Snapshot as a Customer Feature

* Good, Avoids confusion between OpenStack Instance Snapshot and VMware Snapshot.
* Good, Prevents customers from relying on it as a VM rollback mechanism.
* Good, Provides a clearer and more predictable customer experience.
* Good, Reduces potential support cases related to incorrect snapshot expectations.
* Bad, Customers cannot create an instance image using Instance Snapshot through self-service.
* Bad, Customers may need to use another process to create an image from an existing instance.
* Bad, Some use cases may still require Instance Snapshot.
