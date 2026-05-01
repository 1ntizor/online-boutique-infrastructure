import json 
import os

# Define the path to the state file
state_file = os.path.expanduser("~/esxi-infra/terraform.tfstate")

print("=== Terraform Infrastructure Parser ===")

# Check if the file exists
if not os.path.exists(state_file):
    print(f"Error: {state_file} not found.")
    exit(1)

# Load the JSON data
with open(state_file, "r") as file:
    data = json.load(file)

print(f"File loaded. Terraform version: {data.get('terraform_version')}")
print("-" * 40)

# Iterate through resources to find virtual machines
for resource in data.get("resources", []):
    if resource.get("type") == "vsphere_virtual_machine":
        for instance in resource.get("instances", []):
            attributes = instance.get("attributes", {})
            name = attributes.get("name")
            ip = attributes.get("default_ip_addresses") or "No IP assigned yet"

            print(f"Resources: {name}")
            print(f"Status:    {attributes.get('power_state')}")
            print(f"IP:        {ip}")
            print("-" * 40)
