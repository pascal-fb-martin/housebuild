#!/bin/bash
#
# Copyright 2020, Pascal Martin
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
# HouseInstall: install all necessary applications from the House suite.
#
# This script handles both the initial install and later updates.
#

declare -A installed

forceupdate=0
GITHUB="https://github.com/pascal-fb-martin"

function install () {
    if [[ -v installed[$1] ]] ; then return 0 ; fi
    echo "=== Checking $1"
    if [ -d $1 ] ; then
       pushd $1 > /dev/null
       git pull | grep -q 'Already up to date'
       if [[ $? -ne 0 || $forceupdate -eq 1 ]] ; then
          echo "====== Updating $1"
          make rebuild
          sudo make $MAKEINSTALL
          if [[ $2 -ne 0 ]] ; then forceupdate=1 ; fi
       fi
    else
       echo "====== Installing $1"
       git clone $GITHUB/$1.git
       pushd $1 > /dev/null
       make rebuild
       sudo make $MAKEINSTALL
       if [[ $2 -ne 0 ]] ; then forceupdate=1 ; fi
    fi
    popd > /dev/null
    installed[$1]=1
}

# Identify the Linux distribution
ID=unknown
if [[ -e /etc/os-release ]] ; then
    source /etc/os-release
elif [[ -e /usr/lib/os-release ]] ; then
    source /usr/lib/os-release
fi
INSTALLTARGET=install-${ID_LIKE:-$ID}

# Install third party dependencies (on Debian and Void for now)
case ${ID_LIKE:-$ID} in
  debian)
    sudo apt install gcc make git libssl-dev icoutils libgpiod-dev uuid-dev tcl-dev
    ;;
  devuan)
    sudo apt install gcc make git libssl-dev icoutils libgpiod-dev uuid-dev tcl-dev
    ;;
  void)
    sudo xbps-install gcc make git openssl-devel icoutils libuuid-devel tcl-devel
    ;;
  *)
    echo "Warning: $ID is not an explicitly supported environment"
    INSTALLTARGET=install
    ;;
esac

# Always check that houseinstall is up-to-date first.
#
MAKEINSTALL=install
install housebuild 1
if [[ $forceupdate -eq 1 ]] ; then
   echo "====== Reloading $0"
   exec $0 $*
   exit
fi

# The "dev" option only installs development libraries. FOR DEVELOPERS ONLY.
# The "update" (or "upgrade") option updates all repositories that are
# already present. All these option are exclusive (first argument only).
#
if [[ "x$1" = "xdev" ]] ; then INSTALLTARGET=dev ; shift ; fi
isupdate=0
if [[ "x$1" = "xupgrade" ]] ; then isupdate=1 ; fi
if [[ "x$1" = "xupdate" ]] ; then isupdate=1 ; fi

projects=$*
if [[ $isupdate -gt 0 ]] ; then
   shift
   presents=
   for d in `ls` ; do
      if [ -d $d/.git ] ; then presents="$presents $d" ; fi
   done
   projects=`echo "$presents $*" | xargs`
fi

# Implicitely include common dependencies and accept short names:
#
install echttp 1
MAKEINSTALL=$INSTALLTARGET
install houseportal 1

for s in $projects ; do
   case $s in
      clock|houseclock)
          s=houseclock
          ;;
      mech|housemech)
          s=housemech
          ;;
      sun|housesun)
          s=housesun
          ;;
      almanac|housealmanac)
          s=housealmanac
          ;;
      depot|housedepot)
          s=housedepot
          ;;
      saga|housesaga)
          s=housesaga
          ;;
      linux|houselinux)
          s=houselinux
          ;;
      dvr|housedvr)
          s=housedvr
          ;;
      motion|housemotion)
          s=housemotion
          ;;
      sensor|housesensor)
          s=housesensor
          ;;
      tuya|housetuya)
          s=housetuya
          ;;
      kasa|housekasa)
          s=housekasa
          ;;
      wiz|housewiz)
          s=housewiz
          ;;
      relays|houserelays)
          s=houserelays
          ;;
      cimis|housecimis)
          s=housecimis
          ;;
      sprinkler|housesprinkler)
          if [[ ! -d housesprinkler || -d houserelays ]] ; then
             install houserelays 0
          fi
          install waterwise 0
          ## The CIMIS web site does not like high query traffic and requires
          ## setting up an access key, so don't install it by default.
          # install housecimis 0
          s=housesprinkler
          ;;
      lights|houselights)
          install orvibo 0
          install housewiz 0
          install housekasa 0
          install housetuya 0
          s=houselights
          ;;
      test|housetest)
          s=housetest
          ;;
   esac
   install $s 0
done

