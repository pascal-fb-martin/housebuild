
SHARE=/usr/local/share/house

all:

rebuild:

install:
	mkdir -p /usr/local/bin
	mkdir -p /var/lib/house
	mkdir -p /etc/house
	rm -f /usr/local/bin/houseinstall
	cp houseinstall.sh /usr/local/bin/houseinstall
	chmod 755 /usr/local/bin/houseinstall
	chown root:root /usr/local/bin/houseinstall

uninstall:
	rm -f /usr/local/bin/houseinstall

