Setup Simple OpenVPN server for Amazon Linux, Centos, Ubuntu, Debian
====================================================================

Script has been tested on Amazon EC2:
    Amazon Linux AMI 2013.09,
    Red Hat Enterprise Linux 6.4,
    Ubuntu Server 12.04.2 LTS
Rackspace:
    Centos 6.4,
    Ubuntu 12.04 LTS (Precise Pangolin),
    Debian 6.06 (Squeeze),
    Debian 7 (Wheezy)

User documentation is quite lacking currently.

Patches preferably as Github pull requests are welcome!

GPL version 2 licensed easy-rsa tools and example configuration copied
from OpenVPN project, Copyright (C) 2002-2010 OpenVPN Technologies, Inc.
See OPENVPN-COPYING.txt

Other parts Copyright 2012-2013 Viljo Viitanen <viljo.viitanen@iki.fi>
Licensed under GPL version 2. 

INSTALLATION INSTRUCTIONS
=========================

**Amazon EC2, all images**

- Allow UDP port 1194 through the firewall ("security group")

**Amazon Linux 2013.09**

- Just continue to the common instructions

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

    wget https://github.com/viljoviitanen/setup-simple-openvpn/archive/master.zip
    unzip master
    cd setup-simple-openvpn-master
    sudo sh setup.sh

- Let the script run. Take note if the server external ip address
  detection is succesful. If it's not, you need to edit the
  configuration files before using them.

- Download the configuration files from directory setup-simple-openvpn-master/openvpn.*,
  there is both a zipped file with all the config files and
  the plain configuration files

- Get your openvpn client to use the files.

    On Windows, after installing openvpn, just place the files in the openvpn
    configuration directory, shortcut link to the config dir is in the start menu.
    Also note, on Windows you need to run the OpenVPN GUI with administator
    privileges.

    On many Linux desktops, start VPN connection manager, and IMPORT the
    simpleopenvpn.ovpn file, make the vpn not start automatically.
    Do not move the certificate files afterwards, they are needed.
    Author has tested this on Ubuntu 12.04, the package to apt-get is
    network-manager-openvpn-gnome . If you create the connection manually,
    note you need to enable LZO compression in advanced settings.

- Enjoy your very own VPN!

Some notes
==========

You can change the default port (1197) and protocol (udp) on the command
line when starting the setup. See ``sh setup.sh -h`` for details. This is
useful if the default port/protocol are blocked. If you have trouble
connecting to the vpn with the defaults, try ``sudo sh setup.sh 443 tcp``
(443 is the https port, it's rarely blocked). If you have an external
firewall like with Amazon EC2, remember to open the port/protocol there.

Clients are configured to use Google public dns servers when
the vpn connection is active: https://developers.google.com/speed/public-dns/

Only one client certificate is generated, but it can be used simultaneously
with multiple connections. To generate more client certificates, see the
commented lines in the setup script.

If you keep the vpn server generated with this script on the internet for a
long time (days or more), consider either restricting access to the ssh port on
the server by ip addresses to the networks you use, if you know the addresses
you are most likely to use or at least change ssh from port 22 to a random
port.
