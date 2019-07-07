ROLES
---
Scaffolding di un role: tool ansible-galaxy
ansible-galaxy init --offline --init-path roles/ apache
Il comando tree restituisce:
.
└── apache
    ├── defaults
    │   └── main.yml
    ├── files
    ├── handlers
    │   └── main.yml
    ├── meta
    │   └── main.yml
    ├── README.md
    ├── tasks
    │   └── main.yml
    ├── templates
    ├── tests
    │   ├── inventory
    │   └── test.yml
    └── vars
        └── main.yml

9 directories, 8 files

In un playbook per Apache, quello che vogliamo ottenere è:
a) Installare httpd --> Modulo yum o apt.
b) Avviare il servizio httpd --> Modulo service.
c) Copiare la configurazione e i documenti html --> Modulo copy.

Per far ciò, creeremo ogni singolo task nella cartella tasks del role appena creato, utilizzando un file YAML separato, e importando i passi all'interno del main.yml fornito, in modo da avere la 
seguente situazione:

tasks
├── config.yml
├── install.yml
├── main.yml
└── service.yml

Nel file main.yml importiamo i file di task separati:
# tasks file for apache
---
  - import_tasks: install.yml
  - import_tasks: service.yml

Nella top directory del progetto, si definisce il playbook, app.yml, che contiene stavolta un riferimento al ruolo (o ai ruoli) che si deve richiamare:
---
  - name: playbook for app server
    hosts: app
    become: true
    roles:
      - apache

Notare che qui l'attributo roles sostituisce l'attributo tasks degli esempi precedenti.

Per determinare su quali host è stato installato apache è possibile lanciare il comando:
ansible -b -a "which httpd" app
oppure 
ansible -b -a "service httpd status" app


