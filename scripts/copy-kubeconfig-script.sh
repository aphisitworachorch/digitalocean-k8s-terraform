#!/bin/bash
chmod +x /tmp/kubeconfig
mkdir -p ${HOME}/.kube
cp -R -n /tmp/kubeconfig ${HOME}/.kube/config
