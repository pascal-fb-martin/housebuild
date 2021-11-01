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
# HouseDev: rebuild all necessary applications from the House suite.
#
# CAUTION: this script is similar to houseinstall.sh, except that it just
# force a rebuild of all items found. Useful for developpers only.
#

declare -A built

function rebuild () {
    if [[ -v built[$1] ]] ; then return 0 ; fi
    (
     if [ -d $1 ] ; then
        cd $1
        echo "=== Rebuilding $1"
        make rebuild
        if [[ $2 -ne 0 ]] ; then sudo make dev ; fi
     fi
    )
    built[$1]=1
}

# Implicitely include common dependencies and accept short names:

projects=$*
if [[ "x$1" = "xupdate" ]] ; then projects=`dirname */Makefile` ; fi

rebuild housebuild 1
rebuild echttp 1
rebuild houseportal 1

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
             install houserelays
          fi
          rebuild waterwise 0
          s=housesprinkler
          ;;
      lights|houselights)
          rebuild orvibo 0
          rebuild housewiz 0
          s=houselights
          ;;
   esac
   rebuild $s 0
done

