#!/usr/bin/env bash

# Update the distribution software.
echo "Attempting to update the distribution ...";
apt update -yq && apt full-upgrade -yq && apt autoremove -yq
