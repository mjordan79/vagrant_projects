DEPLOYMENTS STRATEGIES
---
Un deployment controller non è nient'altro che un super set di un Replica Set.
Supporta tutte le feature di un Replica Set con l'addizione di nuove feature per l'update strategy.
Creare un deployment significa comunque deployare un Replica Set.
Il minimo nella spec che distingua un deployment da un replica set è la strategy di update:
strategy: 
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 2
      maxUnavailable: 1
revisionHistoryLimit: 4
paused: false

Quando si aggiorna un manifest di deployment già deployato con:
kubectl apply -f manifest-deployment.yaml
esso entrerà in modalità update seguendo la strategy di update contenuta.
La modalità update viene seguita utilizzando i parametri maxSurge e maxUnavailable.
La history per il rollback è definita da revisionHistoryLimit e si traduce nel numero di ReplicaSet conservati.

1) Se è RollingUpdate, è possibile seguire lo stato dell'update con:
kubectl rollout status deployment <deployment>

2) Controllare il numero di revision di rollback e quali sono:
kubectl rollout history deployment <deployment>

3) Avere una descrizione piu dettagliata della revision in questione:
kubectl rollout history deployment <deployment> --revision=<n>

4) Effettuare un rollback a una revision particolare:
kubectl rollout undo deployment <deployment> --to-revision=<n>

5) Scalare un deployment (lo stato è visualizzabile realtime con kubectl rollout status):
kubectl scale deployment <deployment> --replicas=<n>

6) Editare un deployment, questa volta a differenza del Replica Set il risultato si aggiorna realtime :
kubectl edit deployment <deployment>

7) Aggiornare l'immagine del container per un deployment:
kubectl set image deployment <deployment> <nomecontainer>=<immagine:tag>