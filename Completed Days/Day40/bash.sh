kubectl get pods -o=jsonpath='{.items[0].metadata.labels.run}'
kubectl get pods -o=jsonpath='{.items[1].metadata.labels.run}'