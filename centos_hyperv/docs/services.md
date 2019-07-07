SERVICES
---
Un service serve per fare application discovery attraverso un DNS e load balancing.
Consiste nel rendere disponibile l'applicazione dal container al mondo esterno al cluster.

Il manifest base di un service è il seguente:
apiVersion: v1
kind: Service
metadata:
    name: vote-svc
    labels:
        role: vote
spec:
    selector:
        role: vote
        version: v1
    ports:
        - name: web
          port: 80
          targetPort: 80
          nodePort: 30000 
    type: NodePort
    [facoltativo]
    externalIPs:
        - 192.168.137.175
        - 192.168.137.94
        - 192.168.137.134

La parte importante è la sezione ports della spec: port è la porta esposta dal container, targetPort è 
dove mappare tale porta sulla rete interna del Pod (selezionato dai selector) e nodePort è dove mappare
a sua volta tale porta sugli IP dei nodi del cluster. Il tipo è NodePort, ad indicare proprio questo tipo di mapping che si desidera ottenere. 
La targetPort viene mappata anche su un ClusterIP, un IP che contraddistingue il servizio creato ma che è disponibile solo dall'interno dei nodi,
quindi non all'esterno del cluster.
La sezione [facoltativo] dichiara espressamente su quali nodi dev'essere mappata la porta del servizio
ed essere disponibile anche su questi IP di nodo con la porta 80 (la porta che externalIPs usa) oltre che con la nodePort. 
Gli altri IP di nodo che non sono inclusi in questa lista continueranno a usare solo la nodePort.

SERVICE DISCOVERY
---
Altro utilizzo dei service è quello di rendere disponibili nomi di hostname routabili.
Questo tipo di service è il ClusterIP il cui manifest è il seguente:
apiVersion: v1
kind: Service
metadata:
  name: redis
  labels:
    role: redis
    tier: back
  namespace: instavote
spec:
  selector:
    app: redis
  ports:
    - name: redis-db
      port: 6379
      targetPort: 6379
      protocol: TCP
  type: ClusterIP

Non si discosta molto dal NodePort (che ha la stessa funzione ma in piu mappa la porta sull'IP del nodo).
Questo servizio indica che il suo nome "redis" sarà un hostname risolvibile in un IP (il ClusterIP del servizio) 
accessibile dai pod su cui sarà esposta la porta 6379. Il pod che esporrà tale porta sarà quello selezionato dal selector.
Quello che succede è che viene creato un hostname uguale al nome del servizio, assegnato il ClusterIP del servizio,
creata un'entry DNS redis.instavote.svc.cluster.local. Questo può essere verificato entrando in un container e 
ispezionando il file /etc/resolv.conf. Qui dentro il nameserver presenta l'IP del servizio kube-dns del namespace kube-system.

