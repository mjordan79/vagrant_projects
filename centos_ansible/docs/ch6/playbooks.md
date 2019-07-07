YAML
---
Il linguaggio di descrizione dei metadati ufficiale di Ansible.
Un documento inizia con --- e finisce con ...
I playbook sono scritti in YAML.

PLAYBOOKS:
---
Un playbook è una collezione di plays. Un play è un'associazione fra un host o un gruppo di host su cui eseguire dei task. Un task non è nient'altro che una serie di esecuzioni di moduli che servono per raggiungere lo scopo del task.
Quindi:
.--------------------.
. PLAYBOOK (YAML)    .
.--------------------.
.  Host } Play 1     .
.  Task }            .
.    - module        .
.    - module        .
.--------------------.
.  Host } Play 2     .
.  Task }            .
.    - module        .
.    - module        .
.--------------------.

Esempio di Play:
---
- name: App Server Configuration
  hosts: app
  become: true
  become_user: admin
  become_method: sudo
  vars:
    apache_port     = 8080
    max_connections = 4000
    ntp_conf        = /etc/ntp.conf
  tasks:
    - name: create app user
      user: name=app state=present uid=5002

    - name: install git
      yum:  name=tree state=present
...

Gli Ansible Modules sono anche detti Task Plugins.
become va inteso come un sudo. In Ansible può prendere il psoto di sudo, su, pfexec, doas, pbrun, dzdo, ksu e altri.

I task dovrebbero sempre avere il campo name per essere auto documentati.
Scrivere quindi un task come:
- name: Install ntp 
  yum:  name=ntp state=present

anzichè solo:
- yum: name=ntp state=present

I task multiline possono essere definiti con un ">", per esempio:
- name: create dojo user
  user: >
    name=dojo
    uid=5001
    home=/home/dojo
    state=present

oppure:
- name: create dojo user
  user: |
    name=dojo
    uid=5001
    home=/home/dojo
    state=present

oppure:
- name: create dojo user
  user:
    name:dojo
    uid:5001
    home: /home/dojo
    state: present

Un playbook può essere lanciato con il comando:
ansible-playbook

Qualche esempio:

1) Lancio di playbook con dry run
ansible-playbook -i <inventory> playbook --check

2) Controllo della sintassi del playbook
ansible-playbook playbook --syntax-check

3) Listing dei task presenti nel playbook:
ansible-playbook playbook --list-tasks

4) Listing degli host su cui si applica il playbook:
ansible-playbook playbook --list-hosts

5) Listing dei tag che sono presenti nei task:
ansible-playbook playbook --list-tags

6) Iniziare l'esecuzione a un task particolare:
ansible-playbook playbook --start-at="Install git dvcs"

7) Limitare l'esecuzione del playbook solo a un particolare host o gruppo:
ansible-playbook playbook --limit <host>

DEBUGGING
---
C'è qualche opzione che ci consente di fare un po di debugging nel caso le cose
vadano male.
Quando c'è un errore Ansible esce e fornisce un parametro per riprendere l'esecuzione sui
nodi sul quale si è verificato un errore:
ansible-playbook playbook --limit @/tmp/playbook.retry

playbook.retry contiene gli host sul quale si è verificato l'errore.

Un altro tool che è utile per debuggare i task è il parametro step:
ansible-playbook playbook --step

Questo consente di avere la possibilità di eseguire o no un task durante il flusso.

