#!/usr/bin/env bash

UPDATE_DISTRO=$1

if [[ "$UPDATE_DISTRO" == "full" ]]; then
    echo "User chose to upgrade the distro... Doing a full upgrade ...";
    apt update -yq && apt full-upgrade -yq && apt autoremove -yq
elif [[ "$UPDATE_DISTRO" == "upgrade" ]]; then
    echo "User chose NOT to upgrade the distro... Doing an upgrade only ..."
    apt update -yq && apt upgrade -yq && apt autoremove -yq
elif [[ "$UPDATE_DISTRO" == "disabled" ]]; then
    echo "User chose to DISABLE updates. Just make an apt update to update the repo"
    apt update -yq
fi
