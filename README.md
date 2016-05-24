LICENSE
=======

GPLv2 licensed easy-rsa tools and example configuration copied
from OpenVPN project, Copyright (C) 2002-2010 OpenVPN Technologies, Inc.
See OPENVPN-COPYING.txt

Other parts Copyright 2012-2014 Viljo Viitanen <viljo.viitanen@iki.fi>
and Issac Kim https://github.com/iTechnoguy .
Licensed under GPLv2, see LICENSE.txt.

NOTES
=====

Centos 7 and Amazon Linux 2014.09 do not work with this script currently! Centos 6 and Ubuntu 12.04 and 14.04 LTS releases work, possibly some others too.

Installation Instructions
=========================
OpenVZ script is for VPSes that use venet0 instead of eth0, normal script uses eth0.

**RHEL, CentOS, Fedora**

- Install unzip:

```
sudo yum -y install unzip
```

- Enable the EPEL repository. When writing this, it's as simple as:

```
sudo rpm -iv http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
```

  If the link does not work, see instructions at http://fedoraproject.org/wiki/EPEL .
  Also EPEL may already be enabled on your server, so just try to run the setup script.
  The script will complain if it cannot install the openvpn package.

- Continue with the common instructions

**Debian, Ubuntu, and other Debian based distros**

- Install unzip:

```
sudo apt-get -y install unzip
```

- Continue with the common instructions

**Common**

- Make sure you sync your server's clock with NTP or you will be unable to connect to your new VPN server
  due to your SSL certificates being invalid

- Download the repo zip file and run the installation script:

```
wget https://github.com/viljoviitanen/setup-simple-openvpn/archive/master.zip
unzip master.zip
cd setup-simple-openvpn-master
sudo sh normal-setup.sh # or openvz-setup.sh
```

- By default, the script uses UDP 1194, but if you want to use a different
  port run the script with:
```
sudo sh <type>-setup.sh <port #> <protocol>
```
  where port # can be anything between 1-65535, and protocol is either "tcp" or "udp" (no quotes).

- Let the script run. Take note if the server external IP address
  detection is succesful. If it's not, you need to edit the
  configuration files before using them.

- Download the configuration files from directory setup-simple-openvpn-master/openvpn.*,
  there is both a zipped file with all the config files and
  the plain configuration files

Client Installation
===================

In a nutshell: Install an openvpn client, download the client configuration files from server somehow (e.g. with scp), then just use the configuration files. See [Client Installation Guide](https://github.com/viljoviitanen/setup-simple-openvpn/wiki/Client-Installation-Guide) for detailed instructions for Ubuntu, MacOS and Windows 7 desktops. 

To-Do
=====

- Add support for other Linux distros

- Possibly add OS X support

Modifications by Issac Kim
==========================

- Modified for use with OpenVZ VPSes, since they use venet0 instead of eth0.

- Added two versions of the script, one for protocol venet0 specific (openvz-setup.sh), and eth0 (normal-setup.sh).

- The script now creates a Linux specific version, since not all distros support the Windows method of pushing DNS configs, and also needs script-security 2.

- The config files are labeled with the public IP address, and the Linux specific config is labeled with "linux" at the beginning.
