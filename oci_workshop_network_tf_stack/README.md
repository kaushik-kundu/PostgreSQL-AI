# OCI-only workshop test network

This operator stack emulates the requested LiveLabs network in our test tenancy. Deploy it with a user who can manage networking, not with the restricted attendee user. It creates networking only; PostgreSQL and Bastion are provisioned separately.

It provides one IPv4-only private subnet for PostgreSQL and the separately created Bastion's private endpoint. The subnet prohibits public IPs and attaches a restricted security list. The VCN's automatic default security list is also restricted: private-subnet TCP 5432 ingress and OCI-service TCP 443 egress replace its original rules. This default list is not attached to the workshop subnet.

## Network rules

| Component | Rule |
| --- | --- |
| Private route table | Supported regional OCI services through a Service Gateway |
| Security list ingress | Stateful TCP 5432 from the private subnet CIDR |
| Security list egress | Stateful TCP 443 to the regional OCI service CIDR; TCP 5432 to the private subnet CIDR |
| PostgreSQL NSG ingress | Stateful TCP 5432 from the private subnet CIDR |
| PostgreSQL NSG egress | Stateful TCP 443 to the regional OCI service CIDR |

There is no Internet Gateway, NAT Gateway, public subnet, IPv6 connectivity, default internet route, DRG, or peering. Stateful rules allow response traffic for permitted connections. The private TCP 5432 rules accommodate Bastion's private endpoint in the same subnet. If LiveLabs places Bastion's endpoint in another subnet, they must adjust the private source/destination rules accordingly. These CIDR rules allow PostgreSQL access from the subnet; they are not an identity restriction to Bastion alone.

A Service Gateway reaches supported Oracle Services Network services in the same region, rather than every OCI endpoint in every region. See [Oracle Service Gateway documentation](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/servicegateway.htm).

## Deploy the test network

### Resource Manager

Create a separate stack using this folder. Supply the test network `compartment_ocid` and `region`; leave `config_file_profile` unset. Run Plan, review the resources and rules, and then Apply. Use a new VCN rather than importing or modifying an existing network.

### Local Terraform CLI

From this folder, create a local `terraform.tfvars`:

```hcl
compartment_ocid     = "ocid1.compartment.oc1..REPLACE_WITH_TEST_NETWORK_COMPARTMENT"
region               = "us-chicago-1"
config_file_profile  = "ospatraining006"
vcn_cidr             = "10.10.0.0/16"
private_subnet_cidr  = "10.10.1.0/24"
```

The subnet CIDR must be within the VCN CIDR. Adjust both if required for your test environment. The operator needs network management access to the selected compartment.

```bash
terraform init
terraform plan -out network.tfplan
terraform apply network.tfplan
terraform output
```

## Connect the attendee stack

Copy the `psql_subnet_ocid` and `psql_nsg_ocids` outputs into the corresponding inputs of `../oci_postgres_tf_stack`. Its `compartment_ocid` is the attendee database compartment, which can differ from this network compartment. Grant the attendee read/use access to these network resources in their owning compartment.

Create Bastion separately, selecting the `vcn_ocid` and `psql_subnet_ocid` outputs. Set its attendee client CIDR allowlist independently. Once the database exists, create a Bastion port-forwarding session targeting its private IP on TCP 5432 and start the laptop SSH tunnel. The app and model downloads use laptop internet; no app VM is provisioned here.

## Verify the environment

After Apply, audit the deployed VCN: no Internet or NAT Gateway; the private subnet's only attached security list is the restricted one; its only non-local route targets the Service Gateway; the PostgreSQL NSG has the rules above; and public IPs are prohibited on the subnet.

Run the attendee PostgreSQL stack and the app upload/search/OCI Generative AI flow with the temporary user's permissions. A network created by an operator does not itself prove attendee IAM compatibility.

For an active egress test, use a temporary Oracle Linux VM without a public IP in this subnet. Run the following from that VM using an approved private management method, such as OCI instance Run Command. Use the assigned region's OCI endpoint:

```bash
curl --noproxy '*' --connect-timeout 10 --max-time 20 -I https://objectstorage.us-chicago-1.oraclecloud.com/
curl --noproxy '*' --connect-timeout 10 --max-time 20 -I https://1.1.1.1/
```

The OCI request should reach the service; an unauthenticated HTTP error response can still demonstrate HTTPS connectivity. The external request should fail to connect. Run these checks inside the private subnet, not on the attendee laptop or through a PostgreSQL-only tunnel. One blocked external destination is supporting evidence, not an exhaustive test of every destination. Remove the temporary VM and boot volume after testing.

This stack has not yet been applied or tested against the future LiveLabs network. Record the plan, deployed routes/security rules, and test results so they can be compared with that environment when access becomes available.

## Cleanup

Destroy attendee database stacks first, delete Bastion sessions and separately created Bastions, and remove any test VMs/VNICs. Then destroy this network stack. Separate Terraform state does not track dependencies owned by other stacks, so deleting networking first can fail or disrupt active tests.

## Console alternative

The standard **VCN with internet connectivity** wizard creates Internet and NAT Gateways and a NAT route for the private subnet, so its defaults do not match these requirements. A manually created VCN can match them if you explicitly configure the private subnet, Service Gateway, route table, security list, and NSG as above. This stack makes those settings repeatable. See [Oracle's VCN wizard documentation](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/quickstartnetworking.htm).

The older questionnaire described attendee-created networking/Bastion and an Object Storage bucket. The current attendee stack creates PostgreSQL only; LiveLabs provides the network, Bastion is separate, and the bucket has been removed. This test network stack is for the operator's tenancy, not part of attendee provisioning.
