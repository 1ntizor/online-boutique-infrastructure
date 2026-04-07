#!/bin/bash
echo "=== Server Status ==="
kubectl get nodes

echo ""
echo "=== Probles Pods ==="
if [ -z "$1" ]; then
	kubectl get pods -A | grep -v "Running" | grep -v "Completed"
else
	kubectl get pods -n $1 | grep -v "Running" | grep -v "Completed"
fi
