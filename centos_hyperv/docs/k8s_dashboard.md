kubectl proxy --address 0.0.0.0 --accept-hosts '.*'

La dashboard è accessibile all'URL:
http://<master_node>:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/overview?namespace=default

Ultimate Kubernetes Bootcamp:
https://schoolofdevops.github.io/ultimate-kubernetes-bootcamp

