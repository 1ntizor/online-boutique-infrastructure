#!/bin/bash
echo "=== Server Status ==="
kubectl get nodes

echo ""
echo "=== Probles Pods ==="
kubectl get pods -A | grep -v "Running" | grep -v "Completed"
