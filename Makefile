# Copyright 2025, Pascal Martin
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor,
# Boston, MA  02110-1301, USA.
#

prefix=/usr/local

INSTALL=/usr/bin/install

all:

rebuild:

dev:
	$(INSTALL) -m 0755 -d $(DESTDIR)$(prefix)/bin
	$(INSTALL) -m 0755 -T houseinstall.sh $(DESTDIR)$(prefix)/bin/houseinstall
	$(INSTALL) -m 0755 -T housestatus.sh $(DESTDIR)$(prefix)/bin/housestatus
	$(INSTALL) -m 0755 -T houserebuild.sh $(DESTDIR)$(prefix)/bin/houserebuild

install: dev

uninstall:
	rm -f $(DESTDIR)$(prefix)/bin/houseinstall
	rm -f $(DESTDIR)$(prefix)/bin/housestatus
	rm -f $(DESTDIR)$(prefix)/bin/houserebuild

install-debian: install

uninstall-debian: uninstall

install-devuan: install

uninstall-devuan: uninstall

install-void: install

uninstall-void: uninstall

