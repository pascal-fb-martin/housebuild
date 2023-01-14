
SHARE=/usr/local/share/house

all:

rebuild:

dev:
	mkdir -p /usr/local/bin
	mkdir -p /var/lib/house
	mkdir -p /etc/house
	rm -f /usr/local/bin/houseinstall /usr/local/bin/housedev
	cp houseinstall.sh /usr/local/bin/houseinstall
	cp housedev.sh /usr/local/bin/housedev
	chmod 755 /usr/local/bin/houseinstall /usr/local/bin/housedev
	chown root:root /usr/local/bin/houseinstall /usr/local/bin/housedev

install: dev

uninstall:
	rm -f /usr/local/bin/houseinstall /usr/local/bin/housedev

