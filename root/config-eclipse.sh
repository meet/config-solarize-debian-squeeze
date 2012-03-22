#!/bin/bash

set -evx

mkdir -p /opt/MEET/software

release=indigo
version=SR2
variant="jee-$release-$version-linux-gtk"
mirror="http://mirror.switch.ch/eclipse/technology/epp/downloads"
url="$mirror/release/$release/$version/eclipse-$variant.tar.gz"

( cd /opt/MEET/software && wget -N $url )
