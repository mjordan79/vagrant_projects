ROLE BASED ACCESS CONTROL:

Il ruolo è costituito da rules che a loro volta sono costituite da:
  - Risorse accessibii
  - Verbi che definiscono il tipo di accesso

I Role sono associati generalmente ai Namespace. Quando si parla di ruoli che riguardano
risorse sull'intero cluster, allora si parla di ClusterRole.

I Role sono associati agli utenti o ai gruppi di utenti mediante RoleBindings.
Analogamente, i ClusterRole vengono associati mediante ClusterRoleBinding.
Quando l'associazione dev'essere fatta su applicazioni piuttosto che utenti,
si usano invece i ServiceAccount. I ServiceAccount sono bindati all'interno della spec del particolare servizio (Pod, Deployment, StatefulSet, ecc)
e sono anch'essi referenziati all'interno dei RoleBinding o ClusterRoleBindings.


USERS AND GROUPS.
---
Per potersi autenticare, bisogna generare i certificati X.509 firmati dalla cert authority che in questo caso è il nodo master del cluster Kubernetes.

1) Generare la chiave privata per l'utente:
openssl genrsa -out user.key 2048

2) Generare il CSR (Certification Signing Request) per l'utente:
openssl req -new -key user.key -out maya.csr -subj "/CN=maya/O=ops/O=example.org"

3) Firmare il certificato con la CA di Kubernetes usando i certificati in /etc/kubernetes/pki:
openssl x509 -req -CA ca.crt -CAkey ca.key -CAcreateserial -days 730 -in user.csr -out user.crt

4) Associare gli utenti al certificato:
kubectl config set-credentials <user> --client-certificate=/absolute/path/to/user.crt --client-key=/absolute/path/to/user.key

5) Questi utenti possono essere elencati mediante il comando:
kubectl config view

6) Bisogna settare i contesti di un cluster associati ad un utente:
kubectl config get-contexts (Vedere quali cluster sono disponibili)
kubectl config set-context user@<clustername> --cluster=<clustername> --user=user --namespace=<namespace>

7) Connettersi come un utente:
kubectl config use-context kim@kubernetes

8) Impersonare un utente:
kubectl get pods --as=<context-name>

