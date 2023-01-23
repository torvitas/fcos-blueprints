<!-- editorconfig-checker-disable -->
<!-- BEGIN_TF_DOCS -->
# Open VM Tools Ignition Module

[TOC]

## Description

This module returns a butane config that deploys the Open VM Tools for for VMWare virtual machines using the
pod-module.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_butane"></a> [butane](#output\_butane) | n/a |
<!-- END_TF_DOCS -->
The pod definition is roughly based on this blog post:
<https://developers.redhat.com/blog/2017/03/23/containerizing-open-vm-tools-part-1-the-dockerfile-and-constructing-a-systemd-unit-file>
<!-- editorconfig-checker-enable -->
