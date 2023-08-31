#!/usr/bin/env bash

# Update the distribution software.
echo "Attempting to update the distribution ...";
apt-get update -yq && apt-get full-upgrade -yq
