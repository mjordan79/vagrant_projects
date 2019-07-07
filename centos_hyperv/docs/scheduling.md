POD SCHEDULING
---
nodeName:
All'interno della pod spec è possibile inserire un attributo 'nodeName' di tipo stringa.
Questo è il nome del nodo sul quale si vuole schedulare il pod.

nodeSelector:
I node selector schedulano i pod in base a un selettore di nodo.
1) Per vedere le label dei nodi del cluster:
kubectl get nodes --show-labels
2) Per definire le label su un nodo:
kubectl label nodes <nodename> <key1=label1>

L'attributo nodeSelector va nella spec del pod.
nodeSelector: 
    zone: bbb

3) Per vedere i pod di certi nodi con una determinata label si può usare un selector nel comando:
kubectl get pods -o wide --selector="key=label"

La nodeSelector è una hard condition: se il selettore non matcha alcuna condizione, il pod non può
essere schedulato.

affinity:
Modalità di scheduling che consente di definire delle proprietà per il quale il pod deve finire 
su un determinato nodo (node affinity) o sottostare a determinate regole di pod (pod affinity).
L'attributo affinity appartiene sempre alla pod spec. L'affinity consente di definire condizioni dure
(senza le quali il pod non si può schedulare) o soft (senza le quali il pod viene schedulato lo stesso)

NODE AFFINITY
---
Le regole per la node affinity sono sempre di due tipi: obbligatorie (che vanno sempre rispettate)
o di richiesta (sarebbe greadito se si potessero rispettare, senza vincoli stringenti). Un esempio
di spec con node affinity definita:

affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution: (esempio di hard affinity)
      nodeSelectorTerms:
        - matchExpressions:
            - key: node-role.kubernetes.io/master
              operator: DoesNotExist
    preferredDuringSchedulingIgnoredDuringExecution: (esempio di soft affinity)
      - weight: 1
        preference:
          matchExpressions:
            - key: zone
              operator: In
              values:
                - bbb

Questa regola dice che il pod NON deve essere schedulato su un nodo master e preferibilmente andare su un nodo che abbia la label zone=bbb
Le condizioni sono: required, preferred, DuringScheduling, DuringExecution
Gli operatori sono: In, NotIn, Exists, DoesNotExist, Gt, Lt

POD AFFINITY
---
L'affinità di pod prevede l'introduzione di regole per schedulare pod in base a circostanza applicative. Per esempio si vorrebbe poter dire
che un pod dev'essere schedulato soltanto se insieme a un'altra categoria di pod (pod affinity) e rispettare regole per cui non dovrebbe mai essere schedulato insieme ad un'altra categoria di applicazione (antiaffinity).

affinity:
  podAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        podAffinityTerm:
          labelSelector:
            matchLabels:
              role: vote
          topologyKey: kubernetes.io/hostname
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
            - key: role
              operator: In
              values:
                - redis
        topologyKey: kubernetes.io/hostname

Questa affinity descrive che il pod sarebbe gradito che fosse schedulato insieme agli altri che abbiano label con role = vote e debbano essere schedulati sullo stesso nodo (stesso hostname) MA NON DEVE essere schedulato insieme a tutti quelli con label role uguale a redis e quindi andare su nodi diversi (hostname diverso).

TAINT and TOLERATIONS
---
Una taint si applica a un nodo ed è un "marchio" che il nodo possiede.
Si usano per definire quando schedulare o eseguire un pod su un nodo.
Possono essere usate per specificare che tipo di applicazioni eseguire su un nodo. Puo essere usata per fare il cordon di un nodo per manutenzione.
Le tolerations, sui pod, indicano regole per "tollerare" una taint. Quando un pod tollera una taint significa che può essere schedulato sul nodo marcato da quella taint, in altre parole la taint viene ignorata. Le toleration nei pod sono definite nelle spec.

Una taint è costituta come key=value:effect. effect può essere una delle tre possibilità:
NoSchedule, PreferNoSchedule, NoExecute

1) Aggiungere una taint su un nodo:
kubectl taint nodes <nodename> key=value:effect

2) Rimuovere una taint sul nodo che abbiano una determinata chiave:
kubectl taint nodes <nodename> key-

3) Rimuovere una taint sul nodo cha abbia una chiave e un determinato effetto (per esempio NoSchedule):
kubectl taint nodes <nodename> key:NoSchedule-

Tolerations
---
E' importante constatare che se nella pod spec c'è una direttiva nodeName che lega il pod a un particolare nodo, le tolerations per le taint
non funzioneranno. E' pertanto opportuno rimuoverle perchè creano un legame pod / nodo indissolubile.
Nella pod spec:
tolerations:
  - key: dedicated
    operator: Equal
    value: worker
    effect: NoExecute
