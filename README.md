<a name="ventx_logo" href="https://ventx.de">![ventx logo](logo.svg)</a>

# STACKIT FortiGate HA cluster

This project creates a FortiGate HA cluster on STACKIT. It's based on the [example given in the Fortinet OpenStack Administration Guide](https://docs.fortinet.com/document/fortigate-private-cloud/7.6.0/openstack-administration-guide/104035/deploying-two-fortigate-vm-instances-in-an-ha-configuration-in-an-openstack-environment).

## Prerequisites

A STACKIT service account with owner permissions at the organization level is needed. If you don't have one already, follow these steps:

1. In the resource manager, create a dummy project within your STACKIT organization where the service account lives (e. g. `pro-dummy`).
2. In the resource manager, switch to the newly created project and create a service account.
3. Create a service account key for the service account and save it.
4. In the resource manager, switch to your STACKIT organization and assign the owner role to the service account.

The following tools need to be available on the machine that shall run the code:

* Terraform / OpenTofu

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_stackit"></a> [stackit](#requirement\_stackit) | ~> 0.69.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_stackit"></a> [stackit](#provider\_stackit) | 0.69.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [stackit_image.alpine](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/image) | resource |
| [stackit_image.fortios](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/image) | resource |
| [stackit_key_pair.main](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/key_pair) | resource |
| [stackit_network.ha_sync](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/network) | resource |
| [stackit_network.l](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/network) | resource |
| [stackit_network.private01](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/network) | resource |
| [stackit_network.r](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/network) | resource |
| [stackit_network_interface.alpine_l](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/network_interface) | resource |
| [stackit_network_interface.alpine_r](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/network_interface) | resource |
| [stackit_network_interface.fortigate1_ha_sync](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/network_interface) | resource |
| [stackit_network_interface.fortigate1_network_l](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/network_interface) | resource |
| [stackit_network_interface.fortigate1_network_r](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/network_interface) | resource |
| [stackit_network_interface.fortigate1_private01](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/network_interface) | resource |
| [stackit_network_interface.fortigate2_ha_sync](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/network_interface) | resource |
| [stackit_network_interface.fortigate2_network_l](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/network_interface) | resource |
| [stackit_network_interface.fortigate2_network_r](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/network_interface) | resource |
| [stackit_network_interface.fortigate2_private01](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/network_interface) | resource |
| [stackit_public_ip.alpine_l](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/public_ip) | resource |
| [stackit_public_ip.alpine_r](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/public_ip) | resource |
| [stackit_public_ip.fortigate1](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/public_ip) | resource |
| [stackit_public_ip.fortigate2](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/public_ip) | resource |
| [stackit_resourcemanager_project.fortigate](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/resourcemanager_project) | resource |
| [stackit_security_group.web](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/security_group) | resource |
| [stackit_security_group_rule.ssh](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/security_group_rule) | resource |
| [stackit_server.alpine_l](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/server) | resource |
| [stackit_server.alpine_r](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/server) | resource |
| [stackit_server.fortigate1](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/server) | resource |
| [stackit_server.fortigate2](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/server) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name, e. g. test or prod. | `string` | `"test"` | no |
| <a name="input_owner_email"></a> [owner\_email](#input\_owner\_email) | Your email address. | `string` | n/a | yes |
| <a name="input_public_key_path"></a> [public\_key\_path](#input\_public\_key\_path) | Path to your SSH key public key. | `string` | n/a | yes |
| <a name="input_stackit_organization_id"></a> [stackit\_organization\_id](#input\_stackit\_organization\_id) | Your STACKIT organization ID. | `string` | n/a | yes |
| <a name="input_stackit_service_account_key_path"></a> [stackit\_service\_account\_key\_path](#input\_stackit\_service\_account\_key\_path) | Path to your STACKIT service account key JSON file. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage

1. Make sure the prerequisites are met
2. Assign values to the variables (e. g. through a `.tfvars` file or environment variables)
3. Place the needed Alpine image as `alpine.qcow2` (download [here](https://dl-cdn.alpinelinux.org/alpine/v3.23/releases/cloud/generic_alpine-3.23.3-x86_64-uefi-cloudinit-r0.qcow2)) and the FortiGate KVM image as `fortios.qcow2` (download [here](https://support.fortinet.com/support/#/downloads/vm)) into the project's root folder
4. Run `terraform plan` / `tofu plan` and check if the plan matches your expectations
5. Run `terraform apply` / `tofu apply` to deploy the infrastructure

## Support

If you need help with the usage of this project, feel free to create an issue. For help with STACKIT in general, contact us at stackit@ventx.de and we'll see how we can assist you on your journey with STACKIT 😊

Need help with anything else? Come visit us at [ventx.de](https://ventx.de) to get an overview of what we have to offer!

## Contributing

Ideas for improvements? Create an issue or a pull request!
