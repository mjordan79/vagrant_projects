#!/bin/bash

mkdir -p /opt/portainer
cat << EOF > /opt/portainer/run_portainer.sh
docker volume create portainer_data && \
docker run --name portainer --restart=always -d -p 8000:8000 -p 9443:9443 \
	-v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
EOF
chmod +x /opt/portainer/run_portainer.sh

/opt/portainer/run_portainer.sh
