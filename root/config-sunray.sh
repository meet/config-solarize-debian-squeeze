#!/bin/bash

#
# Install script for Sun Ray on Ubuntu 10.04
# [maxg]
# Based on:
#   http://wwwcip.informatik.uni-erlangen.de/~simigern/sunray-debian/4.1.html
#

set -evx

if [ ! -f srss_apt_installed ]
then
  #
  # Install prerequisites
  # Assumes LDAP server, GDM, etc. already installed
  #

  apt-get install gawk nscd pdksh alien devscripts && touch srss_apt_installed
fi

source="http://meet.mit.edu/assets/internal/sunray"

if [ ! -d srss ]
then
  #
  # Download the Sun Ray software
  #

  srsszip="srss_4.1_linux.zip"
  [ ! -r "$srsszip" ] && wget "$source/$srsszip"
  unzip "$srsszip" -d srss
  rm "$srsszip"
fi

if [ ! -f srss_debs_installed ]
then
  #
  # Convert RPMs to Debian packages and install
  #

  for rpm in srss/*/*/Linux/Packages/SUNW*.rpm
  do
    alien --to-deb "$rpm"
  done

  dpkg -i *.deb && touch srss_debs_installed && rm -rf sun*.deb
fi

if [ ! -f srss_patched ]
then
  #
  # Apply patches
  #

  patch="sray41-debian.patch.2008-10-30"
  [ ! -r "$patch" ] && wget "$source/$patch"

  (cd / && patch -p0 ) < "$patch"
  touch srss_patched && rm "$patch"
fi

if [ ! -f srss_sun_java ]
then
  #
  # Needs a particular Sun JRE?
  #
 
  workdir="$PWD"
  ( cd /etc/opt/SUNWut && "$workdir"/srss/*/Supplemental/Java_Runtime_Environment/Linux/jre-1_5_0_11-linux-i586.bin )
  ( cd /etc/opt/SUNWut && ln -s jre1.5* jre )
  touch srss_sun_java
fi

#
# Keyboard
#
mkdir -p /var/lib/xkb
( cd /opt/SUNWut/lib/xkb
  if [ ! -h compiled ]
  then
    if [ -d compiled ]
    then
      mv compiled compiled.bak
    fi
    ln -s /var/lib/xkb compiled
  fi
  if [ ! -h xkbcomp ]
  then
    ln -s /usr/bin/xkbcomp
  fi)
( cd /usr/share/X11
  if [ ! -h xkb ]
  then
    if [ -d xkb ]
    then
      mv xkb xkb.bak
    fi
    ln -s /opt/SUNWut/lib/xkb
  fi )

#
# Config
#
mkdir -p /etc/sysconfig
echo -e "DHCPD_CONF_INCLUDE_FILES\nDHCPD_INTERFACE" > /etc/sysconfig/dhcpd
echo "DISTRIB_ID=Debian" > /etc/lsb-release
[ ! -f /etc/dhcp3/dhcpd.conf.orig ] && cp /etc/dhcp3/dhcpd.conf /etc/dhcp3/dhcpd.conf.orig
( cd /etc/X11
  if [ ! -h XF86Config ]
  then
    ln -s xorg.conf XF86Config
  fi ) # XXX NO SUCH CONFIG FILE
( cd /usr/share/X11
  if [ ! -h fonts ]
  then
    ln -s ../fonts/X11 fonts
  fi )

#
# Init script
#
if [ ! -f /etc/init.d/zsunray-init ]
then
  z=zsunray-init
  [ ! -r $z ] && wget "$source/$z"
  cp $z /etc/init.d/ && chmod 755 /etc/init.d/$z && update-rc.d $z defaults 99 01
fi

# XXX if [ ! -f srss_usb_etc ]
# XXX then
# XXX   #
# XXX   # Audio/Serial-IO/USB-Storage
# XXX   #
# XXX 
# XXX   apt-get install linux-headers-`uname -r`
# XXX 
# XXX   diff="modules-4.1beta.diff"
# XXX   [ ! -r $diff ] && wget "$source/$diff"
# XXX 
# XXX   ( cd /usr/src/ && patch -p0 --forward || true ) < $diff
# XXX 
# XXX   make -C /usr/src/SUNWut/utadem clean default install
# XXX   make -C /usr/src/SUNWut/utio clean defalut install
# XXX   make -C /usr/src/SUNWut/utdisk clean default install
# XXX 
# XXX   touch srss_usb_etc
# XXX fi

# XXX utdomount!!!

#
# Initial config
#
/etc/init.d/utsyscfg stop || true
/etc/init.d/utsyscfg start

( cd /etc/opt/SUNWut/compatlinks
  if [ ! -h liblber.so.199 ]
  then
    ln -s /usr/lib/liblber-2.4.so.2 liblber.so.199
  fi
  if [ ! -h libldap.so.199 ]
  then
    ln -s /usr/lib/libldap-2.4.so.2 libldap.so.199
  fi )

#
# New install setup
#

if [ ! -f srss_ut_basic ]
then
  # === README ===
  # Configure Sun Ray Web Administration? no-
  # Configure Sun Ray Kiosk Mode? no (default)
  # Configure this server for a failover group? no (default)
  # ==============

  /opt/SUNWut/sbin/utconfig
  touch srss_ut_basic
fi

if [ ! -f srss_ut_net_0 ]
then
  # === README ===
  # Accept as is? NO
  # host address: 192.168.10.251
  # netmask: 255.255.255.0 (default)
  # host name: solarize-eth0 (default)
  # offer IP addresses? YES (default)
  # first Sun Ray address: 192.168.10.100
  # number of Sun Ray addresses to allocate: 100
  # auth server list file name: <leave blank> (default)
  # auth server IP address: <leave blank> (default)
  # broadcasting on the network? YES (default)
  # firmware server: 192.168.10.251 (default)
  # router: 192.168.10.251 (default)
  # Accept the updated config
  # Warning... fix? YES (default)
  # ==============
  
  sudo /opt/SUNWut/sbin/utadm -a eth0
  ( cd / git checkout -- etc/dhcp3/dhcpd.conf etc/hosts etc/network/interfaces )
  touch srss_ut_net_0
fi
  
if [ ! -f srss_ut_net_1 ]
then
  # === README ===
  # Accept as is? NO
  # host address: 192.168.20.251
  # netmask: 255.255.255.0 (default)
  # host name: solarize-eth1 (default)
  # offer IP addresses? YES (default)
  # first Sun Ray address: 192.168.20.100
  # number of Sun Ray addresses to allocate: 100
  # auth server list file name: <leave blank> (default)
  # auth server IP address: <leave blank> (default)
  # broadcasting on the network? YES (default)
  # firmware server: 192.168.20.251 (default)
  # router: 192.168.20.251 (default)
  # Accept the updated config
  # Warning... fix? YES (default)
  # ==============

  sudo /opt/SUNWut/sbin/utadm -a eth1
  ( cd / git checkout -- etc/dhcp3/dhcpd.conf etc/hosts etc/network/interfaces )
  touch srss_ut_net_1
fi

/etc/init.d/zsunray-init stop || true

/opt/SUNWut/sbin/utadm -L on

/etc/init.d/dhcp3-server stop || true
/etc/init.d/dhcp3-server start

/etc/init.d/zsunray-init start
