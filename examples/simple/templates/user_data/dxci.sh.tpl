#!/bin/sh

/etc/eks/bootstrap.sh ${cluster_name} --kubelet-extra-args '${kubelet_extra_args}'

exit 0
