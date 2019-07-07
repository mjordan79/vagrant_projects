DASHBOARD:
---
a) Creare un ServiceAccount per admin-user:
apiVersion: v1
kind: ServiceAccount
metadata:
        name: admin-user
        namespace: kube-system

b) Creare un ClusterRoleBinding per l'admin-user:
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kube-system

c) Deployare la dashboard:
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml

d) Editare il servizio kubernetes-dashboard all'interno del namespace kube-system e aggiungere il tipo NodePort in sostituzione del ClusterIP specificando un externalIPs:
"type": "NodePort",
    "externalIPs": [
      "192.168.137.94"
    ],

e) Trovare il token per la login:
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')

f) Accedere la dashboard all'URL:
https://192.168.137.94/#!/service/kube-system/kubernetes-dashboard

Senza la NodePort bisogna creare un proxy:
kubectl proxy --address 0.0.0.0 --accept-hosts '.*'

ed è accessibile all'URL:
http://<master_node>:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/overview?namespace=default