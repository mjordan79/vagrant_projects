NAMESPACES:
---
I namespace forniscono un partizionamento del cluster, dove ogni risorsa è raggruppata e indipendente dagli altri oggetti all'interno del cluster in namespaces differenti.
L'unità minima per definire un manifest di namespace è:

apiVersion: v1
kind: Namespace
metadata:
    name: instavote

1) Visualizzare quali contesti sono disponibili:
kubectl config get-contexts

2) Per cambiare namespace via CLI, bisogna associare al contesto corrente un namespace:
kubectl config set-context $(kubectl config current-context) --namespace=<namespace>

3) Visualizzare i namespaces presenti sul cluster:
kubectl get namespaces (o get ns)

4) Visualizzare a quale namespace ci si sta riferendo nella CLI:
kubectl config view (Se non vengono visualizzati ns significa che si è nel default)

REPLICA SETS:
---
L'unica differenza tecnica fra un Replica Set e un Replication Controller è il selector, al quale viene aggiunta una sintassi per una set-based selection. 
I Replica Set sono la nuova generazione per definire la fault-tolerance dei pod. Non solo definiscono criteri per selezionare pod a cui si riferiscono,
ma sono anche il modo per lanciare dei pod: infatti contengono una sezione template, dove c'è una spec che definisce il pod da lanciare.

Il manifest base di un ReplicaSet è il seguente:
apiVersion: apps/v1
kind: ReplicaSet
metadata:
    name: vote
spec:
    replicas: 5
    minReadySeconds: 10
    selector:
        matchLabels:
            role: vote
        matchExpressions:
            - {key: version, operator: In, values: [v1, v2, v3]}
    template:
        Qui va la definizione del pod a partire dai metadata e includendo la spec.

Durante il lancio di un Replica Set, vengono instanziati i pod. Se esiste già un pod che viene selezionato come valido da un selector, viene mantenuto
inalterato, purchè rientri nel numero di istanze specificate nell'attributo replicas del Replica Set.

Se modifichiamo la spec di un pod lanciato tramite Replica Set tramite kubectl edit, i pod istanziati non vengono modificati a runtime. Solo se un pod muore per qualche motivo, allora viene rilanciato con la nuova configurazione.
Se cancelliamo con kubectl delete pod una qualche istanza, il Replica Set reinstanzia i pod morti.

1) Visualizzare i Replica Set disponibili nel namespace:
kubectl get replicasets (o get rs) [--namespace=<namespace>]

2) Informazioni su un Replica Set:
kubectl describe replicasets (o describe rs) <replicaset>

3) Cancellare un Replica Set (e quindi a cascata tutti i pod selezionati):
kubectl delete replicasets <replcaset>

4) Editare il manifesto di un Replica Set a runtime:
kubectl edit replicaset <replicaset>

5) Scalare un Replica Set (ma anche un Deployment o uno Stateful Set):
kubectl scale --replicas=x replicaset <replicaset> porta lo scaling al nuovo valore di replicas.
kubectl scale --current-replicas=x --replicas=y replicaset <replicaset> scala su y solo se x è verificato.
