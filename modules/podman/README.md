<!-- BEGIN_TF_DOCS -->
# Podman Ignition Module

[TOC]

## Description

This module returns a butane config that configure podman.

## Features

Currently, the following things are implemented:

- mount a block device to /var/lib/containers
- add a systemd drop-in for the podman-kube service template, which is provided by the podman package by default

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_device"></a> [device](#input\_device) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_butane"></a> [butane](#output\_butane) | n/a |
<!-- END_TF_DOCS -->
