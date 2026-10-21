# [HIGIO-0001] Discontinue The LDAP Integration

* Status: reviewed
* Deciders: Kurihara, Okizaki, Nguyen Don Bao Tran, Nguyen Van Hau 
* Date: [2026-06-16]

## Context and Problem Statement

* Context: Integrate multiple identity protocols, including OpenID and LDAP, with OpenStack for user authentication and identity management.
* Problem Statement: When integrating LDAP with OpenStack, users from domains other than the Default domain are not displayed or accessible. This limitation prevents proper management and visibility of users across multiple domains.

## Decision Drivers

* Support multiple identity protocols for authentication.
* Ensure user visibility and management across all domains.
* Minimize operational complexity and integration issues.

## Considered Options

* 1. OpenID Protocol
* 2. LDAP Protocol

## Decision Outcome

Choose option 1 (OpenID Protocol) as the primary authentication solution Because:
* It is better suited for a cloud service provider environment. Adopt OpenID connect (OIDC) as the primary identity protocol for IAM Portal integration and Single Sign-On (SSO) in a multi-tenant environment.
* We have already successfully integrated OIDC with the HIGIO Portal.
* User, role, and group mapping have been implemented and validated by IIJVN Team.
* OIDC provides SSO, federation, and MFA capabilities that align with our current and future requirements
* We have an experienced development team capable of supporting, troubleshooting, and maintaining the integration.

Discontinue LDAP integration because:
* it conflicts with the current OIDC implementation
* LDAP is currently used only for Operations Team authentication to satisfy security audit requirements. We will evaluate alternative solutions for this use case or wait for enhanced Keystone support that can better accommodate both OIDC and LDAP authentication mechanisms without conflicts.

## Pros and Cons of the Options <!-- optional -->

### 1: OpenID Protocol

* Good, Provides Single Sign-On (SSO) and centralized authentication.
* Good, Supports multi-tenancy and federation with multiple Identity Providers (IdPs).
* Good, Well suited for customer portals and external users.
* Good, Supports modern security features such as Multi-Factor Authentication (MFA).
* Good, Enables seamless integration across cloud-native applications and services.
* Bad, More complex to integrate and configure.
* Bad, User/group and role mapping can be challenging.
* Bad, Troubleshooting federation and token-based authentication may require additional expertise.

### 2: LDAP Protocol

* Good, Easy to integrate with legacy enterprise systems.
* Good, Commonly used for internal user authentication and directory services.
* Good, Provides centralized user and group management.
* Good, Simple and mature technology with broad enterprise adoption.
* Bad, Does not provide Single Sign-On (SSO) natively.
* Bad, Does not support Multi-Factor Authentication (MFA) without additional solutions.
* Bad, Less suitable for federated authentication and external customer access.
* Bad, Not designed for modern web and cloud-native authentication scenarios.
* Bad, limited support for multi-domain user visibility within OpenStack.
  
## Links

* Backlog Items
  - [This is  a design limitation of Keystone - Official OpenStack documentation](https://docs.openstack.org/keystone/latest/admin/configuration.html)
  - [LDAP integration evidence and test results](https://github.com/IIJ-Global-Solutions-Vietnam/higio-platform/issues/1)