#!/bin/sh

/etc/eks/bootstrap.sh ${eks_cluster_name} --kubelet-extra-args '--node-labels=eks.amazonaws.com/nodegroup=${eks_node_name},eks.amazonaws.com/nodegroup-image=${eks_node_ami_id}'

exit 0