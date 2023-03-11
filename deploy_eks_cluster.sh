#!/bin/bash

eksctl create cluster --name=cluster-00 --region=eu-north-1 --zones=eu-north-1a,eu-north-1b --without-nodegroup || echo "Cluster already exist"