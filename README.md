<!-- BEGIN_TF_DOCS -->
# Terraform Ignition Blueprints

 [TOC]

## Description

Provide a baseline configuration for Ignition/Butane based workloads.

## References

* <https://coreos.github.io/butane/config-fcos-v1_4/>

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_butane"></a> [butane](#input\_butane) | Custom butane configuration | `string` | `null` | no |
| <a name="input_node_exporter_enabled"></a> [node\_exporter\_enabled](#input\_node\_exporter\_enabled) | Enable node-exporter container | `bool` | `true` | no |
| <a name="input_open_vm_tools_enabled"></a> [open\_vm\_tools\_enabled](#input\_open\_vm\_tools\_enabled) | Enable VMware open-vm-tools to integrate with vSphere | `bool` | `false` | no |
| <a name="input_passwd_ssh_authorized_keys"></a> [passwd\_ssh\_authorized\_keys](#input\_passwd\_ssh\_authorized\_keys) | List of authorized SSH public keys of the default user | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_passwd_username"></a> [passwd\_username](#input\_passwd\_username) | Name of the default user | `string` | `"core"` | no |
| <a name="input_podman"></a> [podman](#input\_podman) | Configuration object for podman module.<br>    Currently only the device attribute that accepts a block device path is available. | <pre>object({<br>    device = string<br>  })</pre> | `null` | no |
| <a name="input_pods"></a> [pods](#input\_pods) | List of configuration objects for pod module. | <pre>list(object({<br>    name     = string<br>    manifest = string<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_config"></a> [config](#output\_config) | War CT config object |
| <a name="output_rendered"></a> [rendered](#output\_rendered) | Rendered ignition config |
<!-- END_TF_DOCS -->
