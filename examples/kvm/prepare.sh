#! /bin/bash

podman run --pull=always --rm -v "$PWD/images":/data:rw,z -w /data \
    quay.io/coreos/coreos-installer:release download -s "stable" -p qemu -f qcow2.xz --decompress
