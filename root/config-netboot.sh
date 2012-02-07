#!/bin/bash

set -evx

wget -N http://ftp.nl.debian.org/debian/dists/squeeze/main/installer-i386/current/images/netboot/netboot.tar.gz

mkdir -p netboot
tar x -C netboot -z -f netboot.tar.gz

rm -rf /srv/tftp/debian-installer-squeeze
cp -r netboot/debian-installer /srv/tftp/debian-installer-squeeze

cp netboot/version.info /srv/tftp/debian-installer-squeeze/

git checkout -- /srv/tftp/
