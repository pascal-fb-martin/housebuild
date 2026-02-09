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
# HouseDeploy: install all listed debian package to a new apt repository.
#
# This script was meant for creating a private apt repository,
# not a repository published on the Internet. Even while this
# repository is signed (and the key is kept private), there
# was no security audit of the publising method below. Use caution.
#
# This is a rather primitive and clumsy use of aptly. The goal here
# is not to manage or maintain apt repositories using aptly, only
# to use aptly as a tool to generate a repository.
#
# NOTE:
#
# On the apt client side, set the apt source (.list) file as follow:
#   deb http://<host>/debian bookworm main
# and copy http://<host>/debian/house.asc to /etc/apt/trusted.gpg.d
#
GPG_ID="pascal.fb.martin@gmail.com"
PUBLIC=/usr/local/share/house/public

. /etc/os-release
DEB_DIST=$VERSION_CODENAME
echo "=== Building for Debian distribution $DEB_DIST"

# Extract the Aptly configuration to retrieve the path to its database
mkdir -p ~/tmp
aptly config show > ~/tmp/aptly$$.conf
eval APTLY_DB=`echttp_get -r ~/tmp/aptly$$.conf .rootDir`
rm -f ~/tmp/aptly$$.conf
if [[ "x$APTLY_DB" = "x" ]] then
    echo "No aptly DB found"
    exit 1
fi
SNAPSHOT="debian-`date '+%Y%m%d-%H%M%S'`"

echo "=== Annihilating any pre-existing aptly database in $APTLY_DB"
mkdir -p $APTLY_DB
rm -rf $APTLY_DB/*

echo "=== Creating repository 'debian'"
aptly repo create -distribution=$DEB_DIST -component=main -comment="The House applications repository" debian

# This could do a wide "aptly repo add debian .", but this might catch
# unwanted package some day..
#
for i in `find . -name build` ; do
    aptly repo add debian $i | grep -v "Loading packages"
done
aptly snapshot create $SNAPSHOT from repo debian
aptly publish snapshot $SNAPSHOT

# Copy the repository to the HousePortal public area
#
# The distribution name is part of the root path to support multiple ones.
# I do realize that aptly can generate repository with multiple distributions,
# but the mechanisms to select which packages go where remain obscure to me.
# The goal here is very limited: facilitate the transition during upgrades
# by not destroying the existing repository right away. The development
# machines would upgrade first: while testing the upgrade the not-yet
# upgraded machines can still access an appropriate repository.
# 
echo "=== copy to the public web site tree ($PUBLIC/debian/$DEB_DIST)"
sudo mkdir -p $PUBLIC/debian/$DEB_DIST
sudo rm -rf $PUBLIC/debian/$DEB_DIST/*
sudo cp -a $APTLY_DB/public/* $PUBLIC/debian/$DEB_DIST

# Publish the public key:
echo "=== Publish the public key to $PUBLIC/debian/house.asc"
gpg --armor --export $GPG_ID | sudo tee -a $PUBLIC/debian/house.asc > /dev/null

