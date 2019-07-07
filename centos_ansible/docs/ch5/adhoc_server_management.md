CONFIGURAZIONE
---
E' buona norma includere nei propri repository la configurazione di Ansible, per esempio ansible.cfg
Grazie al sistema di override della configurazione, un file ansible.cfg che si trova nella root directory di un progetto
viene preso in considerazione come file di configurazione primario, scavalcando di fatto ciò che è contenuto in /etc/ansible/ansible.cfg.
Per ispezionare la configurazione è possibile utilizzare il comando ansible-config:

1) Dump del contenuto del file di configurazione
ansible-config view

2) Dump della configurazione globale di Ansible:
ansible-config dump

3) ansible-config list

HOSTS
---

File specifico per definire host o gruppi di host con cui Ansible deve comunicare.
Quello di default si trova in /etc/ansible/hosts, tuttavia è referenziato in ansible.cfg con
la direttiva inventory quindi anche questo file può essere portato nel codice degli ambienti.
Per esempio, nel file ansible.cfg:
inventory = environments/prod
indica che gli hosts si trovano nel file prod.

Un esempio di raggruppamento di hosts:
[app]
app1
app2

[db]
db1
db2
db3

Questo ci consente di referenziare gruppi di host mediante il nome del gruppo.

HOST PATTERNS
---
Quando si referenziano gruppi di host è possibile utilizzare host patterns, una sintassi
per specificare meglio gruppi:

ansible -m ping app --> seleziona app1 e app2
ansible -m ping app:db --> seleziona app1, app2, db1, db2, db3
ansible -m ping app[0] --> seleziona app1
ansible -m ping 'db:!db2' --> seleziona db1 e db3
ansible -m ping 'db[1:2]' --> seleziona un range fra 1 e 2 inclusivi
ansible -m ping all --limit app1 --> limita la selezione a app1

Tutte le operazioni avvengono in parallelo. Se si vuole limitare il numero di fork,
è possibile utilizzare il paramtro -f
ansible -m ping all -f 1 --> Effettua solo un'operazione su un host alla volta.

COMANDI AD-HOC
---
Per passare un qualche paramtro a un modulo o lanciare un comando grezzo, utilizzare il parametro -a:
ansible all -a "free" --> Esegue il comando free su ogni host
ansible all -m group -a "name=admin state=present" --> Passa parametri al modulo group

Se si richiede sudo per eseguire un comando, dobbiamo usare -b oppure --become:
ansible all -b -a "yum install -y nano"

Se si effettuano comandi NON idempotenti, come ad esempio adduser:
ansible all -b -a "adduser pippo"
la prima volta verranno eseguiti correttamente, la seconda volta daranno un errore.
In questo caso quindi bisogna utilizzare i MODULI di Ansible.

MODULES
---

Stato desiderato. Consente di astrarre la configurazione in termini di "COSA" si vuole e non "COME". 
Per listare la lista di moduli disponibile:
ansible-doc --list
Per vedere esempi di utilizzo con uno snippet:
ansible-doc -s <module>
I moduli sono di due tipo: Core e Community, i Core sono ufficiali.

Esempio di utilizzo moduli:
1) Creare un gruppo con il modulo group:
ansible -b -m group -a "name=admin state=present" all
2) Creare un utente con il modulo user:
ansible -b -m user -a "name=devops group=admin createhome=yes" all
3) Copiare un file con il modulo copy:
ansible -b -m copy -a "src=/vagrant/test.txt dest=/tmp/test.txt" all

COMMAND MODULES:
Sono moduli che consentono di eseguire comandi direttamente sugli ambienti. Da usare in tutti quei casi in cui non c'è o non si possa utilizzare un modulo specializzato per qualche task.
Per esempio il modulo 'raw' consente di eseguire comandi bypassando il sottosistema di moduli di Ansible eseguento comandi ssh, utile nei casi in cui l'ambiente target per esempio non abbia Python installato. Oppure il modulo command che esegue comandi senza passare per una shell (le variabili d'ambiente e altri facility di shell non saranno disponibili), il modulo shell che esegue il comando su un nodo utilizzando /bin/sh o il modulo script che copia uno script sul nodo e lo esegue. Il modulo expect esegue un comando e risponde alle richieste di input interattivo.

1) Invocare un comando con command
ansible -m command -a "free" prod

2) Invocare un comando con shell
ansible -m shell -a "free -m | grep -i swap" prod

3) Invocare un comando con raw
ansible -m raw -a "free -m | grep -i swap" prod

I command modules non sono generalmente idempotenti. Per esempio il comando:
ansible -m command -a "mkdir /tmp/test" prod
genererà un errore se eseguito due volte.
Ci sono tuttavia attributi per renderli idempotenti, per esempio per il command module e la creazione di file o directory, c'è la direttiva creates che informa Ansible l'intenzione di creare un file o una directory e in caso essa esista già fa avvenire direttamente uno skip senza generare un'errore. Per esempio:

ansible -m command -a "mkdir /tmp/test creates=/tmp/test" prod

ANSIBLE REPL
---
La console di Ansible consente di usare i moduli direttamente senza passare per la riga di comando classica dove si deve specificare un parametro -m per stabilire il modulo piu' altri parametri per passare delle opzioni. La console di Ansible si avvia con:
ansible-console -b <group>
per restringere i comandi ad un gruppo di host dell'inventory.

? <Invio> per listare tutti i moduli disponibili
? <modulo> per visualizzare una guida del modulo in questione.

Con questa REPL è possibile usare direttamente il modulo, passando i parametri richiesti. Per esempio, per il modulo command, 
anzichè utilizzare la riga di comando classica: 
ansible -b -m command -a "parametri" prod
è possibile digitare:
command mkdir /tmp/test creates=/tmp/test

oppure 

yum name=nmap state=present

Il comando di repl list-hosts visualizza gli host al quale si applicano i comandi.
