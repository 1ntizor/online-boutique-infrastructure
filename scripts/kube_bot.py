import subprocess 

print("=== Checking Cluster Nodes via Python ===")

# Tell Python to run 'kubectl get nodes' and capture the text output
result = subprocess.run(["kubectl", "get", "pods", "-A"], capture_output=True, text=True)


# Print the captured result to the screen
print("=== Successful Output ===")
print("=== Problem Pods ===")
for line in result.stdout.splitlines():
    if "Running" not in line:
        print(line)

print("=== Errors (if any) ===")
print(result.stderr)

