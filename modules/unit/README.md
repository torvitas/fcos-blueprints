<!-- BEGIN_TF_DOCS -->
# User Unit Ignition Module

[TOC]

## Description

This module returns a butane config that deploys a user unit.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_group"></a> [group](#input\_group) | The group that should run the unit. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the unit to be deployed. | `string` | n/a | yes |
| <a name="input_unit"></a> [unit](#input\_unit) | Unit file content. | `string` | n/a | yes |
| <a name="input_user"></a> [user](#input\_user) | The user that should run the unit. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_butane"></a> [butane](#output\_butane) | n/a |
<!-- END_TF_DOCS -->
