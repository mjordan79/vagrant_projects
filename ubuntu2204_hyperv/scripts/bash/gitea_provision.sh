#!/usr/bin/env bash

NO_NODE=$1

if [ "$NO_NODE" -eq 1 ]
then 
    echo "Provisioning Gitea 1.17.0 ..."
    wget -O gitea https://dl.gitea.io/gitea/1.17.0/gitea-1.17.0-linux-amd64
    chmod +x gitea
    # Installing MySQL ...
    dnf install -yq mysql mysql-server
    systemctl enable --now mysqld
    # We create an user for Gitea
    useradd git -d /home/git
    # Creating the Gitea directory structure
    mkdir -p /var/lib/gitea/{custom,data,log}
    chown -R git:git /var/lib/gitea/
    chmod -R 750 /var/lib/gitea/
    mkdir -p /etc/gitea
    chown root:git /etc/gitea
    chmod 770 /etc/gitea
    # Copying the binary in an appropriate place.
    mv gitea /usr/local/bin
    cat <<EOF > /etc/systemd/system/gitea.service
[Unit]
Description=Gitea (Git with a cup of tea)
After=syslog.target
After=network.target
###
# Don't forget to add the database service dependencies
###
#
Wants=mysql.service
After=mysql.service
#
#Wants=mariadb.service
#After=mariadb.service
#
#Wants=postgresql.service
#After=postgresql.service
#
#Wants=memcached.service
#After=memcached.service
#
#Wants=redis.service
#After=redis.service
#
###
# If using socket activation for main http/s
###
#
#After=gitea.main.socket
#Requires=gitea.main.socket
#
###
# (You can also provide gitea an http fallback and/or ssh socket too)
#
# An example of /etc/systemd/system/gitea.main.socket
###
##
## [Unit]
## Description=Gitea Web Socket
## PartOf=gitea.service
##
## [Socket]
## Service=gitea.service
## ListenStream=<some_port>
## NoDelay=true
##
## [Install]
## WantedBy=sockets.target
##
###

[Service]
# Modify these two values and uncomment them if you have
# repos with lots of files and get an HTTP error 500 because
# of that
###
#LimitMEMLOCK=infinity
#LimitNOFILE=65535
RestartSec=2s
Type=simple
User=git
Group=git
WorkingDirectory=/var/lib/gitea/
# If using Unix socket: tells systemd to create the /run/gitea folder, which will contain the gitea.sock file
# (manually creating /run/gitea doesn't work, because it would not persist across reboots)
#RuntimeDirectory=gitea
ExecStart=/usr/local/bin/gitea web --config /etc/gitea/app.ini
Restart=always
Environment=USER=git HOME=/home/git GITEA_WORK_DIR=/var/lib/gitea
# If you install Git to directory prefix other than default PATH (which happens
# for example if you install other versions of Git side-to-side with
# distribution version), uncomment below line and add that prefix to PATH
# Don't forget to place git-lfs binary on the PATH below if you want to enable
# Git LFS support
#Environment=PATH=/path/to/git/bin:/bin:/sbin:/usr/bin:/usr/sbin
# If you want to bind Gitea to a port below 1024, uncomment
# the two values below, or use socket activation to pass Gitea its ports as above
###
#CapabilityBoundingSet=CAP_NET_BIND_SERVICE
#AmbientCapabilities=CAP_NET_BIND_SERVICE
###
# In some cases, when using CapabilityBoundingSet and AmbientCapabilities option, you may want to
# set the following value to false to allow capabilities to be applied on gitea process. The following
# value if set to true sandboxes gitea service and prevent any processes from running with privileges
# in the host user namespace.
###
#PrivateUsers=false
###

[Install]
WantedBy=multi-user.target
EOF
        systemctl enable --now gitea
        MAINDB=gitea
        PASSWDDB=gitea
        mysql -e "CREATE DATABASE IF NOT EXISTS ${MAINDB} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
        mysql -e "CREATE USER IF NOT EXISTS ${MAINDB}@localhost IDENTIFIED BY '${PASSWDDB}';"
        mysql -e "GRANT ALL PRIVILEGES ON ${MAINDB}.* TO '${MAINDB}'@'localhost';"
        mysql -e "FLUSH PRIVILEGES;"
else
    echo "Not on the first node. No need to provision anything..."
fi