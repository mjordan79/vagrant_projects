# Complete Istio Bootcamp

[![Istio](https://istio.io/favicons/android-72x72.png)](https://istio.io)

### Traffic Management - Gestione avanzata del traffico di rete fra microservices.
Istio supporta diverse features di traffic management per aumentare la resiliency di un'applicazione, attraverso un Envoy Proxy iniettato all'interno di un pod Kubernetes come sidecar container. Ogni microservice, quindi, dispone di un Envoy proxy all'interno del suo pod che effettua un completo hijack del traffico di rete, in modo che i microservizi possano comunicare esclusivamente tramite Envoy stesso. La comunicazione può essere cifrata mediante protocolo mTLS e viene gestita da un modulo Istio detto Mixer, che, fra le altre cose, si occupa anche dell'observability dei servizi mediante distributed tracing.
Le feature supportate per il traffic management sono:
  - Timeouts - Se entro un certo tempo il servizio non risponde, l'applicazione decide di non visualizzare i dati di quel particolare servizio.
  - Retries - Riprovare a chiamare un servizio di continuo, senza rompere l'applicazione se i dati non sono disponibili.
  - Circuit Breakers - Aggiungere un numero di richieste massime per un servizio. Se il threshold viene superato, definire delle rules o degli handlers per gestire la situazione su cosa dev'essere fatto.
  - Intelligent Load Balancing - Istanze multiple di un servizio che vengono contattate in modo bilanciato. Le politiche di balancing sono completamente configurabili e vanno oltre il semplice round-robin di default applicato da un Service Kubernetes.
  
Come detto tutto il traffic management avviene mediante un Envoy sidecar container all'interno di un pod Kubernetes e viene gestito automaticamente da Istio senza alcuna modifica all'applicazione. Tutte le configurazioni e regole definite vengono iniettate nell'Envoy Proxy mediante un modulo detto Pilot. La configurazione viene validata e gestita da un altro modulo, chiamato Galley.

### Fault Injection - Simulare problematiche reali per testare la resilienza dell'applicazione.
Funzionalità simili a Netflix Chaos Monkey, un software che risiede frapposto in un una rete di microservizi e inizia ad applicare problematiche ai servizi in modo random, come distruggere VM di nodi o deallocare container. La fault injection prevede molti casi di problematiche reali: service overload, network failure, indisponibilità di un servizio, ecc. Istio gestisce tutte queste problematiche introducendo due tipi di fault: abort e delay di servizi.

### Traffic Mirroring - Testare nuove versioni dell'applicazione in produzione.
Abbiamo un'applicazione in produzione che è già soggetta a un traffico e ad un carico reale. Spesso in fase di testing un simile traffico non può essere replicato: si effettuano dei test di funzionamento dell'applicazione generico ma nulla si sa come reagisce la nuova versione di un servizio sotto un carico reale. Con il traffing mirroring, il traffico generato dall'utenza verso certi servizi di produzione viene duplicato e inoltrato al medesimo servizio che invece è sotto pre-production, staging o testing. Tutto il traffico di produzione quindi subisce un mirroring verso la nuova versione dell'applicazione, consentendo un testing a carico reale senza aver bisogno di interagire manualmente con l'applicazione stessa.

### Observability - Debugging mediante dati telemetrici.
Monitorare le risorse hardware e il traffico di rete spesso non è sufficiente e comunque capire quali problemi ci sono a livello applicativo durante un funzionamento sotto carico è estremamente difficile. Istio implementa il concetto di distributed tracing, effettua un monitoring e un logging di tutte le request e response delle chiamate coinvolte in una catena di microservizi con i tempi di risposta in modo da individuare rapidamente qual è il servizio problematico nella catena di chiamate.
Istio genera questi dati tramite un modulo, chiamato Mixer, che è in grado di collegarsi, mediante plugin, ai piu disparati servizi di data-injection come Prometheus e Grafana. I traces sono generati mediante OpenTracing API e possono essere esplorati mediante Jaeger sia a livello di metriche sia visualizzati come DAG (Directed Acyclic Graphs).

### Tool usati in una distribuzione standard di Istio

Istio utilizza un buon numero di tool open source per implementare le funzionalità che offre:

* [Envoy] - Edge e Service Proxy progettato per applicazioni cloud-native.
* [Prometheus] - Sistema di monitoring e database per time-series data.
* [Grafana] - Visualizzazione dati e monitoring.
* [Kiali] - Observability per Service Mesh.
* [Jaeger] - Distributed Tracing.
