#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color



echo -e "${YELLOW}=== Server Status ===${NC}"
kubectl get nodes

echo ""
echo -e "${RED}=== Problems Pods ===${NC}"
if [ -z "$1" ]; then
	kubectl get pods -A | grep -v "Running" | grep -v "Completed"
else
	kubectl get pods -n $1 | grep -v "Running" | grep -v "Completed"
fi
