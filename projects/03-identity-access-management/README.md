# Identity & Access Management Lab

## Objective
Manage Entra ID identities, groups, roles, and enforce security policies.

## Tasks
1. Create users, groups, and roles.
2. Assign RBAC permissions.
3. Configure Multi-Factor Authentication (MFA).
4. Implement Conditional Access policies.

## Skills Covered
- Entra ID
- RBAC
- Security & Access Management

## Scripts
- `scripts/aad-setup.ps1` → PowerShell script to create users and configure roles

## Steps Completed

1. Use Entra ID to:
    Create users:
        - cloudadmin
        - helpdesk-user
        - readonly-user

    Create groups:
        - Azure-Admins
        - Azure-Readers
    > Set group type to Security and Assign Azure-Admin as the owner
2. Assign users to groups
    - Add Cloudadmin, Helpdesk-user to `Azure-Admin` group
    - readonly-user to `Azure-Readers`
    
3. Assign RBAC Permission
    - From Azure portal
    - Create resource group `Project-03`
    - From `Access Control(IAM)` 
    - Assigned `Contributor` role to Azure-Admin group
    - Assigned `Reader` role to Azure-readers group

4. Configure MFA
    - Enabled **Security Defaults** in Microsoft Entra ID
    - if more fine control available by selecting Security and under protect heading select `Conditional Access`

5. Validated access:
   - Verified `Azure-Admins` users can create and manage resources
   - Verified `Azure-Readers` users have read-only access

