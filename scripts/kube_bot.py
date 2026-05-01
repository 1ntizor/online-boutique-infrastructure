from kubernetes import client, config

print("=== Kubernetes API Bot ===")

config.load_kube_config()

v1 = client.CoreV1Api()

pods = v1.list_pod_for_all_namespaces(watch=False)

print("=== Problem Pods ===")
problems_found = False

for pod in pods.items:
    if pod.status.phase not in ["Running", "Succeeded"]:
        problem_found = True
        print(f"Namespace: {pod.metadata.namespace}")
        print(f"Name:      {pod.metadata.name}")
        print(f"Status:    {pod.status.phase}")
        print("-" * 40)

if not problems_found:
    print("All pods are healthy!")
