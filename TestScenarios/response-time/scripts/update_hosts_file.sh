#!/bin/bash

ingress_ip=$(kubectl get ingress ingress -o jsonpath='{.status.loadBalancer.ingress[*].ip}' | awk -F'%' '{print $1}')
sudo cp /etc/hosts /etc/hosts.bak
echo "$ingress_ip response-time-test grafana prometheus hermes zeuspol hephaestus" | sudo tee -a /etc/hosts