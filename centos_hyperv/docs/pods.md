PODS:
---
Il Pod ha una spec che nella reference è chiamata Pod v1 Core.
Il template base per un pod è un file YAML che contiene:

apiVersion:
kind:
metadata:
spec:

Un pod per l'applicazione vote è:
apiVersion: v1
kind: Pod
metadata:
    name: vote
    labels:
        app: python
        role: vote
        version: v1
spec:
    containers:
        - name: app
          image: schoolofdevops/vote:v1
          ports:
            - containerPort: 80
              protocol: TCP

1) Informazioni sul cluster (master e DNS):
kubectl cluster-info

2) Creare il pod dal file:
kubectl apply -f vote-pod.yml (Crea il pod fisicamente)
kubectl apply -f vote-pod.yml --dry-run (effettua un test sintattico ma non crea il pod)

3) Quali pod ci sono nel namespace corrente:
kubectl get pods
kubectl get pods -n <nome_namespace> (visualizzare i pod di un  namespace)
kubectl get pods -o wide per avere inoltre l'IP del pod e il nodo su cui è schedulato.
kubectl get pods <podname>
kubectl get pods <podname> -o yaml (per ottenere info sul pod in formato YAML, lo stesso di kubectl edit)
kubectl get pods <podname> --show-labels (mostra le label associate a un pod)
kubectl get pods -l key=value (ritorna solo la lista di pods che dispongono della label specificata)

4) Quali risorse posso ottenere con kubectl get:
kubectl api-resources

5) Quali versioni di API sono disponibili:
kubectl api-versions

6) Informazioni dettagliate sui pod:
kubectl describe pods (descrive tutti i pod)
kubectl describe pods <podname>

7) Stampare i log di un pod:
kubectl logs <podname>
kubectl logs -f <podname> (Si mette in attesa e segue il flusso di logs)
kubectl logs <podname> -c <containername> (Visualizza i log di uno specifico container in un pod)
kubectl logs -l key=value (Per visualizzare i log di tutti i pod che hanno una determinata label)

8) Eseguire un comando all'interno di un pod:
kubectl exec -it <podname> <cmd> (si collega al container di default)
kubectl exec -it <podname> <cmd> -c <containername> (si collega al container specificato)

9) Forwardare una porta dal container all'host:
kubectl port-forward <podname> hostPort:containerPort

10) Editare la configurazione di un pod in esecuzione:
kubectl edit pod <podname>

11) Eliminare un pod:
kubectl delete pod <podname>
kubectl delete pod --grace-period=0 --force <podname> (Eliminare dei pod forzatamente)

MULTI-CONTAINER PODS:
---
Piu container all'interno di un pod condividono:
  a) Lo stesso hostname (il nome del pod)
  b) Lo stesso IP (che è l'IP del pod)

VOLUMES:
---
I volumi richiedono:
  a) La definizione di un volume con l'attributo volumes all'interno della spec, con un nome e un tipo.
  b) Una definizione volumeMounts all'interno della definizione del container per montare i volumi. 
     Il campo name in questa sezione dev'essere quello del volume definito che si vuole montare.

I volumi per file system locale sono di due tipi: emptyDir e hostPath.

Esempio:
spec:
    containers:
        - name: db
          image: postgres:9.4
          ports:
            - containerPort: 5432
          volumeMounts:
            - name: pg-data
              mountPath: /var/lib/postgresql/data
    volumes:
        - name: pg-data
          hostPath:
            path: /var/lib/postgres
            type: DirectoryOrCreate
