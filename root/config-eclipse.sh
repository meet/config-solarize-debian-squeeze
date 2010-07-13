#!/bin/bash

set -evx

mkdir -p /opt/MEET/software

release=helios
variant="jee-$release-linux-gtk"
mirror="http://mirror.switch.ch/eclipse/technology/epp/downloads"
url="$mirror/release/$release/R/eclipse-$variant.tar.gz"

( cd /opt/MEET/software && wget -N $url )
