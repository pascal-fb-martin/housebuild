
SHARE=/usr/local/share/house

all:

rebuild:

dev:
	mkdir -p /usr/local/bin
	mkdir -p /var/lib/house
	mkdir -p /etc/house
	rm -f /usr/local/bin/housedev
	rm -f /usr/local/bin/houseinstall /usr/local/bin/housestatus /usr/local/bin/houserebuild
	cp houseinstall.sh /usr/local/bin/houseinstall
	cp housestatus.sh /usr/local/bin/housestatus
	cp houserebuild.sh /usr/local/bin/houserebuild
	chmod 755 /usr/local/bin/houseinstall /usr/local/bin/housestatus /usr/local/bin/houserebuild
	chown root:root /usr/local/bin/houseinstall /usr/local/bin/housestatus /usr/local/bin/houserebuild

install: dev

uninstall:
	rm -f /usr/local/bin/housedev
	rm -f /usr/local/bin/houseinstall /usr/local/bin/housestatus /usr/local/bin/houserebuild

install-debian: install

uninstall-debian: uninstall

install-void: install

uninstall-void: uninstall

