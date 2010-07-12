#!/bin/bash

# sudoers
echo 'Defaults mail_always' >> /etc/sudoers
echo '%lab-admins ALL= ALL' >> /etc/sudoers

# Network
apt-get remove --yes --purge network-manager

# Configuration files
GIT=$(mktemp -d)
git clone --no-checkout https://github.com/meet/config-solarize-debian-squeeze.git "$GIT"
mv "$GIT"/.git /
(cd / && git checkout --force)
rm -rf "$GIT"

# NFS
mkdir -p /srv/home
