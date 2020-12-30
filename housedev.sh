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

function rebuild () {
    (
     if [ -d $1 ] ; then
        cd $1
        echo "=== Rebuilding $1"
        make rebuild
     fi
    )
}

# Implicitely include common dependencies and accept short names:

rebuild echttp
rebuild houseportal
rebuild housebuild

for s in $* ; do
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
      sprinkler|housesprinkler)
          if [[ ! -d housesprinkler || -d houserelays ]] ; then
             install houserelays
          fi
          rebuild waterwise
          s=housesprinkler
          ;;
      lights|houselights)
          rebuild orvibo
          s=houselights
          ;;
   esac
   rebuild $s
done

