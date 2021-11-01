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
          sudo make install
          if [[ $2 -ne 0 ]] ; then forceupdate=1 ; fi
       fi
    else
       echo "====== Installing $1"
       git clone $GITHUB/$1.git
       pushd $1 > /dev/null
       make rebuild
       sudo make install
       if [[ $2 -ne 0 ]] ; then forceupdate=1 ; fi
    fi
    popd > /dev/null
    installed[$1]=1
}

# Implicitely include common dependencies and accept short names:

projects=$*
if [[ "x$1" = "xupdate" ]] ; then projects=`ls` ; fi

install housebuild 1
if [[ $forceupdate -eq 1 ]] ; then
   echo "====== Reloading $0"
   exec $0 $*
   exit
fi

install echttp 1
install houseportal 1

for s in $projects ; do
   case $s in
      clock|houseclock)
          s=houseclock
          ;;
      sensor|housesensor)
          s=housesensor
          ;;
      relays|houserelays)
          s=houserelays
          ;;
      wiz|housewiz)
          s=housewiz
          ;;
      sprinkler|housesprinkler)
          if [[ ! -d housesprinkler || -d houserelays ]] ; then
             install houserelays 0
          fi
          install waterwise 0
          s=housesprinkler
          ;;
      lights|houselights)
          install orvibo 0
          install housewiz 0
          s=houselights
          ;;
   esac
   install $s 0
done

