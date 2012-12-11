Setup Simple OpenVPN server for Amazon Linux
============================================

Script is tested on Amazon Linux AMI 2012.09, the default AMI in
"Launch Instance Classic Wizard".

It may be compatible with other rpm based distros too but it's
totally untested.

User documentation is quite lacking currently.

Patches preferably as Github pull requests are welcome!

GPL version 2 licensed easy-rsa tools and example configuration copied
from OpenVPN project, Copyright (C) 2002-2010 OpenVPN Technologies, Inc.
See OPENVPN-COPYING.txt

Other parts Copyright 2012 Viljo Viitanen <viljo.viitanen@iki.fi>
Licensed under GPL version 2. 

INSTALLATION INSTRUCTIONS
-------------------------

Create an Amazon Linux EC2 image.

Allow UDP port 1194 through the firewall

Login to the EC2 machine

then download and run the installation script:

  wget https://github.com/downloads/viljoviitanen/setup-simple-openvpn/openvpn-setup.sh

  sudo sh openvpn-setup.sh

Let the script run. Take note if the server external ip address
detection is succesful. If it's not, you need to edit the
configuration files before using them.

Download the configuration files from directory tmp.*,
there is both a zipped file with all the config files and
the plain configuration files

Get your openvpn client to use the files.

On Windows, after installing openvpn, just place the files in the openvpn
configuration directory, shortcut link to the config dir is in the start menu.
Also note, on Windows you need to run the OpenVPN GUI with administator
privileges.

Enjoy your very own VPN!
