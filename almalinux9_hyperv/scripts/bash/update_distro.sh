#!/usr/bin/env bash

# Update the distribution software.
echo "Attempting to update the distribution ...";
dnf install -yq epel-release && dnf update -yq
