<!-- editorconfig-checker-disable -->
<!-- BEGIN_TF_DOCS -->
# Authorized Keys Ignition Module

[TOC]

## Description

Set up authorized\_keys file for default user `core`.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_authorized_keys"></a> [authorized\_keys](#input\_authorized\_keys) | Set of authorized SSH public keys for the default user | `set(string)` | n/a | yes |
| <a name="input_user"></a> [user](#input\_user) | The user to which to add the public key to the authorized keys to. | `string` | `"core"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_butane"></a> [butane](#output\_butane) | n/a |
<!-- END_TF_DOCS -->
<!-- editorconfig-checker-enable -->
