#!/bin/bash
#
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
# HousePublish: install all listed debian package to the local repository.
#
# This script was meant for creating a private apt repository,
# not a repository published on the Internet. Even while this
# repository is signed (and the key is kept private), there
# was no security audit of the publising method below. Use caution.
#
# NOTE:
# On the apt client side, set the apt source (.list) file as follow:
#   deb http://<host>/debian bookworm main
# and copy http://<host>/debian/house.asc to /etc/apt/trusted.gpg.d
#
GPGID="pascal.fb.martin@gmail.com"
DEBDIST=bookworm
PUBLIC=/usr/local/share/house/public

APTLYDB=`echttp_get ~/.aptly.conf ./rootDir`
SNAPSHOT="debian-`date '+%Y%m%d-%H%M%S'`"

echo "Dropping any existing snapshot (snapshots depends on the repo??)"
aptly publish drop $DEBDIST
for s in `aptly snapshot list -raw` ; do
   aptly snapshot drop $s
done
aptly repo drop debian

echo "Creating repository 'debian'"
aptly repo create -distribution=$DEBDIST -component=main -comment="The House applications repository" debian

# This could do a wide "aptly repo add debian .", but this might catch
# unwanted package some day..
#
for i in `find . -name \build` ; do
    aptly repo add debian $i | grep -v "Loading packages"
done
aptly snapshot create $SNAPSHOT from repo debian
aptly publish snapshot $SNAPSHOT

# Copy the repository to the HousePortal public area
sudo mkdir -p $PUBLIC/debian
sudo rm -rf $PUBLIC/debian/*
sudo cp -a $APTLYDB/public/* $PUBLIC/debian

# Publish the public key:
gpg --armor --export $GPGID | sudo tee -a $PUBLIC/debian/house.asc > /dev/null

