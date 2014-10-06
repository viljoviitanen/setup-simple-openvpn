This is a fork of viljoviitanen's script (https://github.com/viljoviitanen/setup-simple-openvpn).

GPL version 2 licensed easy-rsa tools and example configuration copied
from OpenVPN project, Copyright (C) 2002-2010 OpenVPN Technologies, Inc.
See OPENVPN-COPYING.txt

Other parts Copyright 2012-2013 Viljo Viitanen <viljo.viitanen@iki.fi>
Licensed under GPL version 2. 

INSTALLATION INSTRUCTIONS
=========================


**Centos 6.4, Red Hat Enterprise Linux 6.4**

- Install unzip ::

    sudo yum -y install unzip

- Enable the EPEL repository. When writing this, it's as simple as: ::

    sudo rpm -iv http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm

  If the link does not work, see instructions at http://fedoraproject.org/wiki/EPEL .
  Also EPEL may already be enabled on your server, so just try to run the setup script.
  The script will complain if it cannot install the openvpn package.

- Continue with the common instructions

**Ubuntu 12.04, Debian 6.06, Debian 7**

- Install unzip ::

    sudo apt-get -y install unzip

- Continue with the common instructions

**Common**

- Make sure you sync your server's clock with NTP or you will be unable to connect to your new VPN server
  due to your SSL certificates being invalid

- Download the repo zip file and run the installation script: ::

    wget https://github.com/iTechnoguy/setup-simple-openvpn/archive/master.zip or git clone https://github.com/iTechnoguy/setup-simple-openvpn
    unzip master
    cd setup-simple-openvpn-master
    sudo sh setup.sh

- Let the script run. Take note if the server external ip address
  detection is succesful. If it's not, you need to edit the
  configuration files before using them.

- Download the configuration files from directory setup-simple-openvpn-master/openvpn.*,
  there is both a zipped file with all the config files and
  the plain configuration files


Changes from Original
=====================

Default port is TCP 110, you can use a different port or protocol by running setup.sh with setup.sh <port #> <protocol>
Also modified for use with OpenVZ VPSes, since they use venet0 instead of eth0.
The script now creates a Linux specific version, since not all distros support the Windows method of pushing DNS configs, and also needs script-security 2.
