#!/bin/bash

eksctl create nodegroup \
  --cluster cluster-00 \
  --region eu-north-1 \
  --name workers-00 \
  --node-type t3.large \
  --node-volume-size=21 \
  --managed \
  --nodes 2 \
  --nodes-min 2 \
  --nodes-max 4 \
  --node-private-networking \
  --spot \
  --full-ecr-access \
  --alb-ingress-access || echo "hello"