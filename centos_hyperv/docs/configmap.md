CONFIGMAP
---
La configurazione non dovrebbe essere messa all'interno dell'immagine ma fornita esternamente con qualche meccanismo e iniettata durante la fase di launch.

Una config map è il modo Kubernetes per fornire variabili d'ambiente popolate in fase di runtime.
Il manifest per una config map è il seguente:
apiVersion: v1
kind: ConfigMap
metadata:
  name: vote
  namespace: instavote
data:
  OPTION_A: Visa
  OPTION_B: Mastercard

Le config map vanno referenziate nel container (o nella sezione template di un deployment):
envFrom:
    - configMapRef:
        name: vote-cm

Le config map possono definire stesse variabili d'ambiente ma per namespace differenti. In linea
di massima rimuovendo configurazione "statica" hardcoded è possibile utilizzare i manifest per deinire stesse applicazioni in namespace differenti.

E' possibile inoltre definire una config map da un file di configurazione e montare la config map
nel percorso in cui l'applicazione si aspetta determinati file di configurazione in modo da fornirglieli. In questo caso referenziare una config map del genere è come usare un volume.
Nella spec del pod (anche all'interno di un deployment) va creato un volume che referenzi tale 
config map:

volumes:
    - name: redis
      configMap:
        name: redis-cm

Il volume va poi montato nel modo canonico all'interno della sezione containers:
volumeMounts:
    - name: redis
      subPath: redis.conf
      mountPath: /etc/redis.conf

Questa sezione istruisce il pod ad usare il volume di nome redis che esporta il file redis.conf e 
dice di renderlo disponibile all'applicazione in /etc/redis.conf

1) Quali config map ci sono nel namespace corrente:
kubectl get configmaps (get cm)

2) Informazioni dettagliate su una config map:
kubectl describe configmap <configmap>

3) Creare una config map da un file di conigurazione:
kubectl create configmap --from-file <fileconf> <nomeconfigmap>

SECRET
---
Un secret è una config map che include dati in formato cifrato (opaco), per l'esattezza in formato base64 encoded. In genere un secret ricade (come uso) nelle username e password per le applicazioni.
Bisogna fornrsi quindi le versioni encodate di tali valori:

echo "admin" | base64
YWRtaW4=

echo "password" | base64
cGFzc3dvcmQ=

Definire un secret richiede il seguente manifest:
apiVersion: v1
kind: Secret
metadata:
    name: db-secret
    namespace: instavote
type: Opaque
data:
    POSTGRES_USER: YWRtaW4=
    POSTGRES_PASSWORD: cGFzc3dvcmQ=

Per referenziare un secret, bisogna sempre essere nella spec di un pod (o di un deployment) nella 
sezione containers di un pod (o di un deployment):
env:
    - name: POSTGRES_USER
      valueFrom:
        secretKeyRef:
            name: db-secret
            key: POSTGRES_USER
    - name: POSTGRES_PASSWORD
      valueFrom:
        secretKeyRef:
            name: db-secret
            key: POSTGRES_PASSWORD

IMPORTANTE: Quando si aggiorna una config map o un secret su di un deployment già esistente, questo 
edit non effettuerà un redeployment dell'applicazione. E' necessario quindi rideployare manualmente 
l'applicazione cancellando il vecchio deploy / pod. Questo al momento in cui si scrive è fino a Kubernetes 1.12. Un'implementazione che effettuerà un rollout del deploy su aggiornamento di config maps e secrets è in fase di sviluppo.

1) Quali secret ci sono nel namespace corrente:
kubectl get secrets

2) Descrivere un secret:
kubectl describe secret <secretname>



