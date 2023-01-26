<!-- BEGIN_TF_DOCS -->
# Directory Parents Ignition Module

[TOC]

## Description

This module returns a butane config that ensures a path of directories exists and has the correct permissions.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_group"></a> [group](#input\_group) | The group that should be assigned to the path. | `string` | `null` | no |
| <a name="input_mode"></a> [mode](#input\_mode) | The permissions that should be applied to the path. | `number` | `493` | no |
| <a name="input_path"></a> [path](#input\_path) | Absolute path that should exist. | `string` | n/a | yes |
| <a name="input_root"></a> [root](#input\_root) | Root path that is assumed to already exist. | `string` | n/a | yes |
| <a name="input_user"></a> [user](#input\_user) | The user that should be the owner of the path. | `string` | `"root"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_butane"></a> [butane](#output\_butane) | n/a |
<!-- END_TF_DOCS -->
