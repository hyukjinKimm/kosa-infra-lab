#!/bin/bash
kubeadm init --control-plane-endpoint lb.example.com:6443 --pod-network-cidr 10.244.0.0/16 --upload-certs
