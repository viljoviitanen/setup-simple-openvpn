#!/bin/sh
#    Setup Simple OpenVPN server for Amazon Linux, Centos, Ubuntu and Debian
#    Copyright (C) 2012-2013 Viljo Viitanen <viljo.viitanen@iki.fi>
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
#    2013-10-02: add debian squeeze&wheezy and ubuntu 12.04 compatibility
#                workaround for amazon ec2 rhel 6.4 image bug https://bugzilla.redhat.com/show_bug.cgi?id=956531
#                use http://ipecho.net/plain - http://ipecho.net/developers.html
#    2013-10-06: add port, protocol and server name as optional parameters

#do not use any funny characters here, just lower case a-z. 

OPENVPN='/etc/openvpn'

if [ "x$1" = "x-h" -o "x$1" = "x--help" ]
then
  echo "Usage: $0 [port] [protocol] [servername]"
  echo "Default: port 1194, UDP, servername OpenVPN-<protocol>-<port #>."
  echo "The server name is just for your convinience, it does not"
  echo "have to be related to the dns name of the server."
  exit 0
fi

if [ "x$1" = "x" ]
then
  PORT=1194
else
  PORT=$1
fi

EXIT=0

TEST=`echo "$1" | tr -d [0-9]`
if [ "x$TEST" != "x" ]
then
  echo "Port must be a number."
  EXIT=1
fi

#make absolutely sure it's a simple number, not something silly like 007
PORT=`expr 0 + $PORT`

if [ $PORT -lt 1 -o $PORT -gt 65535 ]
then
  echo "Port must be between 1 and 65535".
  EXIT=1
fi

if [ "x$2" = "x" ]
then
  PROTO="udp"
else
  PROTO=$2
fi

if [ "$PROTO" != "udp" -a "$PROTO" != "tcp" ]
then
  echo "Unknown protocol, must be udp or tcp".
  EXIT=1
fi

if [ "x$3" = "x" ]
then
  ME="openvpn-$PROTO-$PORT"
else
  ME=$3
fi

TEST=`echo "$3" | tr -d [a-zA-Z]`
if [ "x$TEST" != "x" ]
then
  echo "Server name must only contain letters a-z."
  EXIT=1
fi

TEST=`expr length "$3"`
if [ $TEST -ge 64 ]
then
  echo "Server name must be less than 64 characters."
  #it's used in the certificate and config file names 
  EXIT=1
fi

if [ $EXIT = "1" ]
then
  exit 1
fi

if [ $PORT -eq 22 -a "$PROTO" = "tcp" ]
then
  echo "NOTE: you are using the SSH port and protocol."
  echo "Sleeping for 10 seconds, press control-C to abort."
  sleep 10
fi

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
if which apt-get 2>/dev/null
then
   apt-get -y install openvpn zip || {
    echo "============================================================"
    echo "Could not install openvpn and zip with apt-get. Huh?"
    echo "============================================================"
    exit 1
  }
elif which yum 2>/dev/null
then
  yum -y install openvpn zip || {
    echo "============================================================"
    echo "Could not install openvpn and zip with yum." 
    echo "Enable EPEL repository?"
    echo "See http://fedoraproject.org/wiki/EPEL"
    echo "============================================================"
    exit 1
  }
else
  echo "============================================================"
  echo "Cannot find apt-get or yum. Can't continue."
  echo "============================================================"
  exit 1
fi


mkdir -p $OPENVPN || { echo "Cannot mkdir $OPENVPN, aborting!"; exit 1; }

#openvpn config files and easy-rsa tool
cp -r easy-rsa $OPENVPN/
cp template-server-config $OPENVPN/openvpn.conf
sed -i -e "s/VPN_PROTO/$PROTO/" -e "s/VPN_PORT/$PORT/" $OPENVPN/openvpn.conf

if grep -q "cat <<EOL >> /etc/ssh/sshd_config" /etc/rc.d/rc.local
then
  echo "Note: working around a bug in Amazon EC2 RHEL 6.4 image"
  sed -i.bak 19,21d /etc/rc.d/rc.local 
fi

#ubuntu has exit 0 at the end of the file.
sed -i '/^exit 0/d' /etc/rc.local

#set up nat for the vpn
cat >> /etc/rc.local << END
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -I INPUT -p $PROTO --dport $PORT -j ACCEPT

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

#first find out external ip 
#cache the result so this can be tested safely without hitting any limits
if [ `find "$HOME/.my.ip" -mmin -5 2>/dev/null` ]
then
  IP=`cat "$HOME/.my.ip" | tr -cd [0-9].`
  echo "Using cached external ip address"
else
  echo "Detecting external IP address"
  IP=`curl icanhazip.com`
  echo "$IP" > "$HOME/.my.ip"
fi

if [ "x$IP" = "x" ]
then
  IP="UNKNOWN-ADDRESS"
  echo "============================================================"
  echo "  !!!  COULD NOT DETECT SERVER EXTERNAL IP ADDRESS  !!!"
  echo "============================================================"
  echo "Make sure you edit the $ME.ovpn file before trying to use it"
  echo "Search 'UNKNOWN-ADDRESS' and replace it with the correct IP address"
else
  echo "============================================================"
  echo "Detected your server's external IP address: $IP"
  echo "============================================================"
  echo "Make sure it is correct before using the client configuration files!"
fi
sleep 2

TMPDIR=`mktemp -d --tmpdir=. openvpn.XXX` || { echo "Cannot make temporary directory, aborting!"; exit 1; }

cp template-client-config $TMPDIR/$ME.ovpn
cp template-client-config-linux $TMPDIR/linux-$ME.ovpn
cd $TMPDIR || { echo "Cannot cd into a temporary directory, aborting!"; exit 1; }


cp $OPENVPN/easy-rsa/keys/ca.crt "ca-$ME.crt"
cp $OPENVPN/easy-rsa/keys/client1-$ME.key $OPENVPN/easy-rsa/keys/client1-$ME.crt .
sed -i -e "s/VPN_SERVER_ADDRESS/$IP/" -e "s/client1/client1-$ME/" -e "s/^ca ca.crt/ca ca-$ME.crt/" $ME.ovpn
sed -i -e "s/VPN_PROTO/$PROTO/" -e "s/VPN_PORT/$PORT/"  $ME.ovpn
sed -i -e "s/VPN_SERVER_ADDRESS/$IP/" -e "s/client1/client1-$ME/" -e "s/^ca ca.crt/ca ca-$ME.crt/" linux-$ME.ovpn
sed -i -e "s/VPN_PROTO/$PROTO/" -e "s/VPN_PORT/$PORT/"  linux-$ME.ovpn
zip $ME-$IP.zip $ME.ovpn linux-$ME.ovpn ca-$ME.crt client1-$ME.key client1-$ME.crt
chmod -R a+rX .

echo "----"
echo "Generated configuration files are in $TMPDIR/ !"
echo "----"
echo "The server '$ME' uses port $PORT protocol $PROTO."
echo "Make sure they are open in an external firewall if there is one."

#enable openvpn at boot and start server!
if which yum 2>/dev/null
then
  chkconfig openvpn on
fi

service openvpn start

exit 0
