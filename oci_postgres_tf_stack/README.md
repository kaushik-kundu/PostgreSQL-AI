# PostgreSQL workshop stack

This stack creates an OCI Database with PostgreSQL DB System, an optional PostgreSQL configuration, and a generated admin password when one is not supplied. LiveLabs manages networking separately. Bastion and its sessions are created outside this stack.

Until LiveLabs access is available, an operator can create the equivalent private network in our test tenancy using [the separate network stack](../oci_workshop_network_tf_stack/README.md). Copy its subnet and NSG outputs into this stack's inputs.

## Inputs supplied by attendees

| Input | Value |
| --- | --- |
| `compartment_ocid` | Assigned attendee compartment for the database and configuration |
| `region` | Assigned workshop region; defaults to `us-chicago-1` |
| `psql_admin` | Chosen database administrator username |
| `psql_subnet_ocid` | Existing private subnet OCID supplied by LiveLabs; required |
| `psql_nsg_ocids` | Existing PostgreSQL NSG OCIDs supplied by LiveLabs; defaults to `[]` |

The subnet and NSGs can be in another compartment. Supply their OCIDs directly; no network compartment or VCN OCID is required by this stack. The NSGs must be in the subnet's VCN. Attendees need permission to use those resources in their owning compartment and to create PostgreSQL resources in their assigned compartment.

Leave `psql_nsg_ocids` empty only when LiveLabs confirms that subnet security lists provide the required rules. This stack does not create or change any network security rules.

## Network requirements for LiveLabs

- An IPv4-only private subnet in the workshop region, with enough available addresses for concurrent databases and any Bastion endpoints.
- A Service Gateway, route table, and security rules providing required OCI service access without external internet egress.
- Private TCP 5432 connectivity from the separately managed Bastion to the database, including rules on any attached NSGs and applicable subnet security lists.
- Attendee read/use access to the shared subnet and any assigned NSGs.

A Bastion need not exist when this stack is applied. It must be available when attendees connect from their laptops. LiveLabs should confirm whether users can create a Bastion or must use a pre-created one, and grant the permissions needed to create port-forwarding sessions. Configure its client source CIDR allowlist separately.

## Provisioning and cleanup

Upload this folder as a **new** Resource Manager stack, supply the inputs above, and run Plan followed by Apply. Save `postgres_private_ip`, `psql_configuration_id`, and the sensitive `psql_admin_pwd` output. Use the database's connection details to obtain its hostname and CA certificate.

Destroy removes the database and any configuration created by this stack. Shared networking, existing configurations, and separately managed Bastions are not owned by this stack.

Do not apply this revision directly to an older stack that created its own network and Bastion. Removing those resource definitions can propose deleting them, and changing the subnet can require database replacement. Review any migration separately; this change does not migrate an existing database.

The shared-network deployment still needs an end-to-end test with LiveLabs temporary-user permissions and the actual pre-provisioned network.
