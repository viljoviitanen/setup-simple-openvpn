#!/bin/sh
#    Setup Simple OpenVPN server for Amazon Linux and Centos
#    Copyright (C) 2012 Viljo Viitanen <viljo.viitanen@iki.fi>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License version 2
#    as published by the Free Software Foundation.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

#    2012-12-11: initial version, tested only on amazon linux
#    2012-12-12: added centos 6.3 compability
#    2013-03-30: amazon linux 2013.03 - service iptables is missing, use rc.local
#                whatismyip automation has stopped working, use ipchicken.com
#                change from embedded tar gz to repo zip download

#do not use any funny characters here, just lower case a-z. 
SERVERNAME='simpleopenvpn'

OPENVPN='/etc/openvpn'

if [ -d $OPENVPN ]
then
  echo "$OPENVPN exists, aborting!"
  exit 1
fi

if [ ! -f template-client-config ]
then
  echo "Necessary files missing. Run script from same directory where you unzipped the zip file?"
  exit 1
fi

if [ `id -u` -ne 0 ] 
then
  echo "Need root, try with sudo"
  exit 0
fi

#install openvpn, zip and dependencies
yum -y install openvpn || {
  echo "============================================================"
  echo "Could not install openvpn with yum. Enable EPEL repository?"
  echo "See http://fedoraproject.org/wiki/EPEL"
  echo "============================================================"
  exit 1
}

#enable ip forwarding in openvpn startup script
sed -i /etc/init.d/openvpn -e '/proc.sys.net.ipv4.ip_forward/ s/#//'

mkdir -p $OPENVPN || { echo "Cannot mkdir $OPENVPN, aborting!"; exit 1; }

#openvpn config files and easy-rsa tool
cp -r easy-rsa $OPENVPN/
cp template-server-config $OPENVPN/openvpn.conf

#set up nat for the vpn
cat >> /etc/rc.local << END
#openvpn udp port
iptables -I INPUT -p udp --dport 1194 -j ACCEPT

iptables -t nat -A POSTROUTING -s 192.168.2.0/24 -d 0.0.0.0/0 -o eth0 -j MASQUERADE
#default firewall in centos forbids these
iptables -I FORWARD -i eth0 -o tun0 -j ACCEPT
iptables -I FORWARD -i tun0 -o eth0 -j ACCEPT

#not sure if these are really necessary, they probably are the default.
iptables -t nat -P POSTROUTING ACCEPT
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P OUTPUT ACCEPT
END
sh /etc/rc.local

#just to be sure...
ME=`echo "$SERVERNAME" | tr -cd [a-z]`
if [ "x$ME" = "x" ]
then
  ME="simpleopenvpn"
fi

#setup keys
( cd $OPENVPN/easy-rsa || { echo "Cannot cd into $OPENVPN/easy-rsa, aborting!"; exit 1; }
  [ -d keys ] && { echo "easy-rsa/keys directory already exists, aborting!"; exit 1; }
  cp vars myvars
  sed -i -e 's/Fort-Funston/$ME/' -e 's/SanFrancisco/Simple OpenVPN server/' myvars
  . ./myvars
  ./clean-all
  ./build-dh
  ./pkitool --initca
  ./pkitool --server myserver
  ./pkitool client1-$ME
)
#for more client certificates:
# cd easy-rsa
# . ./myvars
# ./pkitool [unique-client-name]
#by default this server allows multiple connections per client certificate

#generate the client config file

#first find out external ip with ipchicken.com
#cache the result so this can be tested safely without hitting any limits
if [ `find "$HOME/.my.ip" -mmin -5 2>/dev/null` ]
then
  IP=`cat "$HOME/.my.ip" | tr -cd [0-9].`
  echo "Using cached external ip address"
else
  echo "Detecting external ip address"
  IP=`curl -s ipchicken.com|egrep '[0-9]+[.][0-9]+[.][0-9]+[.][0-9]+.*<br>' | awk '{print $1}' | tr -cd [0-9]. `
  echo "$IP" > "$HOME/.my.ip"
fi

if [ "x$IP" = "x" ]
then
  IP="UNKNOWN-ADDRESS"
  echo "============================================================"
  echo "  !!!  COULD NOT DETECT SERVER EXTERNAL IP ADDRESS  !!!"
  echo "============================================================"
  echo "Make sure you edit the $ME.ovpn file before trying to use it"
  echo "Search 'UNKNOWN-ADDRESS' and replace it with the correct ip address"
else
  echo "============================================================"
  echo "Detected your server external ip address: $IP"
  echo "============================================================"
  echo "Make sure it is correct before using the client configuration files!"
fi
sleep 2

TMPDIR=`mktemp -d --tmpdir=. openvpn.XXX` || { echo "Cannot make temporary directory, aborting!"; exit 1; }

cp template-client-config $TMPDIR/$ME.ovpn
cd $TMPDIR || { echo "Cannot cd into a temporary directory, aborting!"; exit 1; }

cp $OPENVPN/easy-rsa/keys/ca.crt "ca-$ME.crt"
cp $OPENVPN/easy-rsa/keys/client1-$ME.key $OPENVPN/easy-rsa/keys/client1-$ME.crt .
sed -i -e "s/VPN_SERVER_ADDRESS/$IP/" -e "s/client1/client1-$ME/" -e "s/^ca ca.crt/ca ca-$ME.crt/" $ME.ovpn
zip $ME-$IP.zip $ME.ovpn ca-$ME.crt client1-$ME.key client1-$ME.crt
chmod -R a+rX .
echo "Generated configuration files are in $TMPDIR/ !"

#enable openvpn at boot and start server!
chkconfig openvpn on
service openvpn start

exit 0
