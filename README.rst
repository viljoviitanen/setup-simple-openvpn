Setup Simple OpenVPN server for Amazon Linux and Centos
=======================================================

Script has been tested on Amazon EC2 Linux AMI 2013.09,
Amazon EC2 Red Hat Enterprise Linux 6.4
and Rackspace Centos 6.4.

User documentation is quite lacking currently.

Patches preferably as Github pull requests are welcome!

GPL version 2 licensed easy-rsa tools and example configuration copied
from OpenVPN project, Copyright (C) 2002-2010 OpenVPN Technologies, Inc.
See OPENVPN-COPYING.txt

Other parts Copyright 2012 Viljo Viitanen <viljo.viitanen@iki.fi>
Licensed under GPL version 2. 

INSTALLATION INSTRUCTIONS
=========================

**Amazon Linux 2013.09 on Amazon EC2**

- Create an Amazon Linux EC2 instance.

- Allow UDP port 1194 through the firewall ("security group")

- Login to the server

- Continue with the common instructions

**Red Hat Enterprise Linux 6.4 on Amazon EC2**

- Create a Red Hat Enterprise Linux EC2 instance.

- Allow UDP port 1194 through the firewall ("security group")

- Login to the server

- Fix buggy rc.local file in the image: https://bugzilla.redhat.com/show_bug.cgi?id=956531 ::

    sudo sed -i.bak 19,21d /etc/rc.local
    
  - The original file is left at /etc/rc.local.bak.

- Enable the EPEL repository. When writing this, it's as simple as: ::

    sudo rpm -iv http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm

  If the link does not work, see instructions at http://fedoraproject.org/wiki/EPEL

- Continue with the common instructions

**Centos 6.4 on Rackspace, maybe others too**

- Create a Centos server

- Login to the server

- Install zip and unzip ::

    sudo yum -y install zip unzip

- Continue with the common instructions

**Common**

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
