all:
	tar zcf - client.ovpn openvpn.conf easy-rsa | base64 > tmpfile
	cat setup-source.sh tmpfile > openvpn-setup.sh
	rm -f tmpfile
