
SHARE=/usr/local/share/house

all:

rebuild:

dev:
	mkdir -p /usr/local/bin
	mkdir -p /var/lib/house
	mkdir -p /etc/house
	rm -f /usr/local/bin/housedev
	rm -f /usr/local/bin/houseinstall /usr/local/bin/housestatus
	cp houseinstall.sh /usr/local/bin/houseinstall
	cp housestatus.sh /usr/local/bin/housestatus
	chmod 755 /usr/local/bin/houseinstall /usr/local/bin/housestatus
	chown root:root /usr/local/bin/houseinstall /usr/local/bin/housestatus

install: dev

uninstall:
	rm -f /usr/local/bin/housedev
	rm -f /usr/local/bin/houseinstall /usr/local/bin/housestatus

install-debian: install

uninstall-debian: uninstall

install-void: install

uninstall-void: uninstall

