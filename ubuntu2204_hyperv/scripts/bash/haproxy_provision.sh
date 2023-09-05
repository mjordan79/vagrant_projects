#!/bin/bash

NO_NODE=$1
ENABLE_KUBERNETES=$2
IP_ADDRESS=$(hostname -i)

haproxy_config_file () {
    echo "Writing config file in /etc/haproxy ..."
    mkdir -p /etc/haproxy
    cat << EOF > /etc/haproxy/haproxy.cfg
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

    # Default SSL material location
    ca-base /etc/ssl/certs
    crt-base /etc/ssl/private

    # See: https://ssl-config.mozilla.org/#server=haproxy&server-version=2.0.3&config=intermediate
    ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
    ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
    ssl-default-bind-options ssl-min-ver TLSv1.2 no-tls-tickets

defaults
    log global
    mode http
    option httplog
    option dontlognull
    timeout connect 5000
    timeout client  50000
    timeout server  50000
    errorfile 400 /etc/haproxy/errors/400.http
    errorfile 403 /etc/haproxy/errors/403.http
    errorfile 408 /etc/haproxy/errors/408.http
    errorfile 500 /etc/haproxy/errors/500.http
    errorfile 502 /etc/haproxy/errors/502.http
    errorfile 503 /etc/haproxy/errors/503.http
    errorfile 504 /etc/haproxy/errors/504.http

frontend stats
    bind *:80
    stats enable
    stats uri /
    stats refresh 10s
    stats admin if TRUE

frontend kubernetes-apiserver-frontend
    mode tcp
    option tcplog
    bind $IP_ADDRESS:16443
    default_backend kubernetes-apiserver-backend

backend kubernetes-apiserver-backend
    mode tcp
    option tcp-check
    balance roundrobin
    server kmaster1 192.169.0.22:16443 check fall 3 rise 2
    server kmaster2 192.169.0.23:16443 check fall 3 rise 2
    server kmaster3 192.169.0.24:16443 check fall 3 rise 2
EOF
}

echo "Provisioning HAProxy because enable_kubernetes = true and we're on the first node"

if [ "$ENABLE_KUBERNETES" = "true" -a $NO_NODE -eq 1 ] 
then 
    apt install haproxy -yq
    haproxy_config_file
    systemctl restart haproxy
fi
