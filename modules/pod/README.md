<!-- BEGIN_TF_DOCS -->
# Pod Ignition Module

[TOC]

## Description

This module returns a butane config that deploys and enables a pod as a systemd service.

## Features

Currently, the following things are implemented:

- deploy pod manifest to /usr/local/etc/kube/<pod-name>.yml
- enable pod systemd service via podman-kube service template

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_manifest"></a> [manifest](#input\_manifest) | n/a | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_butane"></a> [butane](#output\_butane) | n/a |
<!-- END_TF_DOCS -->
